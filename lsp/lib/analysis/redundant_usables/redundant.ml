open Tlapm_lib.Util
open Tlapm_lib
open Tlapm_lib.Proof.T
open Tlapm_lib.Expr.T
module Dq = Deque
module Ss = Util.Coll.Ss
module Sm = Util.Coll.Sm
module Is = Util.Coll.Is
module Im = Map.Make (Int)
open Property
open Fmt

let sequent_prop : expr Property.pfuncs = Property.make "Redundant.sequent"

let rear queue = snd(Option.get (Dq.rear queue))

let get_locus wrapped =
  match Util.query_locus wrapped with
  | Some l -> l
  | None -> Loc.unknown

type finding_kind = Fact | Definition
type finding = {
  kind : finding_kind;
  locus : Loc.locus;
}

let get_expression (hyp : hyp) : expr option =
  match hyp.core with
  | Defn (df, _, _, _) ->
      (match df.core with
        | Operator (name, body) ->
            dbg "Expr from hyp %s == %s" name.core (expr_to_string body);
            Some (body.core @@ hyp)
        | _ -> None)
  | _ -> None

let nearest_step_def cx =
  Dq.find ~backwards:true cx (fun h ->
    match h.core with
    | Defn (df, _, _, _) ->
        (match df.core with
         | Operator (hint, {core = At _; _}) ->
            dbg "Found operator - %s" hint.core;
            true
         | _ -> false)
    | _ -> false)

let step_sequent (st : step) : expr option =
  match st.core with
  | Assert (sq, _) | Suffices (sq, _) -> Some sq.active
  | _ -> None

class unused = object (self)
  val mutable items : usable_ctx Dq.dq = Dq.empty

  method start_qed_visit : unit =
    dbg "Start qed visit. Item length - %d. Previous required %d" (Dq.size items) (Dq.size (rear items).required);
    items <- Dq.snoc items {provided = Dq.empty; required = (rear items).required; fact_imports = Dq.empty};

  method start_visit : unit =
    dbg "Start visit. Item length - %d" (Dq.size items);
    items <- Dq.snoc items {provided = Dq.empty; required = Dq.empty; fact_imports = Dq.empty};

  method finish_visit : usable_ctx =
    dbg "Finish visit. Item length - %d" (Dq.size items);
    let visited = self#visited in
    items <- Dq.first_n items (Dq.size items - 1);
    if Dq.size items > 0 then begin
      let old_visited = self#visited in
      self#add_ctx old_visited visited
    end;
    visited

  method add (idx : int) (def : use_def wrapped) : unit =
    dbg "Adding usable - %d" idx;
    let visited = self#visited in
    visited.provided <- Dq.snoc visited.provided {idx = idx; definition = def}

  method add_fact_expressions (idxs : int list) (expr : expr) : unit =
    dbg "Fact - %s. Expressions - %s" (expr_to_string expr) (String.concat ", " (List.map string_of_int idxs));
    let visited = self#visited in
    visited.fact_imports <- Dq.snoc visited.fact_imports {fact = expr; expressions = idxs}

  method mark_used (idx : int) : unit =
    let visited = self#visited in
    visited.required <- Dq.snoc visited.required {idx = idx}

  method visited : usable_ctx = rear items

  method add_ctx(target : usable_ctx) (source : usable_ctx) : unit =
    let provided = Dq.to_list source.provided
      |> List.map (fun (p : provided) -> p.idx) in
    let still_required = Dq.to_list source.required
      |> List.filter (fun (r : required) -> not (List.mem r.idx provided)) in
    target.required <- Dq.append target.required (Dq.of_list still_required);
end

class hyp_expand =
  object (self : 'self)
    inherit [unit] Expr.Visit.iter as super

    val mutable references : int Dq.dq = Dq.empty

    method expand (scx : 's Expr.Visit.scx) (idx : int) : int list =
      dbg "Expand %d" idx;
      let hyp = Option.get (Dq.nth (snd scx) idx) in
      let expr_opt = get_expression hyp in
      (match expr_opt with
       | Some body ->
          self#add_references scx body idx
       | None -> ());
      references |> Dq.to_list

    method! expr scx expr =
      (match expr.core with
      | Ix n ->
          dbg "Original expr - %s" (expr_to_string expr);
          let idx = Dq.size (snd scx) - n in
          let hyp = Option.get (Dq.nth (snd scx) idx) in
          let operator = get_expression hyp in
          (match operator with
          | Some body ->
              self#add_references scx body idx
          | _ -> ())

      | At at -> dbg "At %b" at 
      | _ -> dbg "Other %s" (expr_to_name expr));
      super#expr scx expr

    method add_references scx (expr : expr) (idx : int) : unit =
      match expr.core with
      | At _ ->
        dbg "At step";
        (match Property.query expr sequent_prop with
        | Some sequent ->
          dbg "Active sequent - %s" (expr_to_string sequent);
          self#add_references scx sequent idx
        | None -> (dbg "Sequent not found")
        )
        
      | _ -> 
        let n = Dq.size (snd scx) - idx in
        references <- Dq.snoc references idx;
        let shifted = Expr.Subst.app_expr (Expr.Subst.shift n) expr in
        dbg "Shifted expr - %s" (expr_to_string shifted);
        self#expr scx shifted
  end

class theorem_visitor =
  object (self : 'self)
    inherit Module.Visit.map as m_super
    inherit [unit] Proof.Visit.iter as super

    val mutable active_sequent : expr = At false @@ nowhere

    val unused = new unused
    val mutable redundant : finding list = []

    method redundant = redundant

    method! theorem cx name (sq : sequent) naxs pf orig_pf summ =
      (match pf.core with
       | Omitted (Elsewhere _) ->
         dbg "Skip imported theorem"
       | _ ->
         let thm_name =
           match name with
           | Some n -> n.core
           | None -> "<anonymous>"
         in
         dbg "ENTER theorem %s (cx size %d)" thm_name (Dq.size cx);
         let scx = ((), cx) in
         dbg_cx scx;


         let scx = self#sequent scx sq in
         let scx = self#add_theorem_name scx name in

         self#proof scx pf);
      m_super#theorem cx name sq naxs pf orig_pf summ

    method! qed scx qed_step =
      unused#start_qed_visit;
      super#qed scx qed_step

    method! step scx st =
      let scx = super#step scx st in
      match step_sequent st with
      | None -> scx
      | Some active ->
        (match nearest_step_def (snd scx) with
         | Some (n, _) ->
           let idx = Dq.size (snd scx) - 1 - n in
           dbg "Tagging step def at idx %d with sequent - %s" idx (expr_to_string active);
           let cx = Dq.alter (snd scx) idx (fun old ->
             Property.assign old sequent_prop active) in
           (fst scx, cx)
         | None -> scx)

    method! sequent scx sequent =
      dbg "Sequent start";
      unused#start_visit;
      active_sequent <- sequent.active;
      let result = super#sequent scx sequent in
      dbg "Sequent end";
      result
      

    method! proof scx proof =
      (match proof.core with
       | By _ -> dbg "Proof By"
       | Steps (steps, _) -> dbg "Proof Steps - %d" (List.length steps)
       | Obvious -> dbg "Proof Obvious";
       | _ -> dbg "Proof");

      super#proof scx proof;
      let findings = unused#finish_visit in
      pp_provided findings;
      self#add_findings findings

    method! usable scx us =
      let size = Dq.size (snd scx) in
      us.facts |>
        List.iter (fun exp ->
          match exp.core with
          | Ix n ->
            let idx = size - n in
            dbg "Expanding idx - %d" idx;
            let fact_expressions = (new hyp_expand)#expand scx idx in
            let hyp = Option.get (Dq.nth (snd scx) idx) in
            let is_operator = Option.is_some (get_expression hyp) in
            if is_operator then
              unused#add_fact_expressions fact_expressions exp
          | _ -> dbg "Unrecognized fact"
        );
      us.defs |>
        List.iter (fun def ->
          match def.core with
          | Dx n ->
              let idx = size - n in
              dbg "Usable def - %d" idx;
              unused#add idx def
          | _ -> ());

    method! definition cx df wd vsbl local =
      (match df.core with
       | Operator (_, expr) -> dbg "dfn expression '%s'" (expr_to_string expr)
       | _ -> ());
      dbg "Definition";
      m_super#definition cx df wd vsbl local

    method! expr scx expr =
      dbg "expression '%s'" (expr_to_string expr);
      (match expr.core with
       | Ix n ->
           dbg "Ix %d expr" n;
           self#add_required_def scx n
       | _ -> ());
      super#expr scx expr

    method add_findings (usable_ctx : usable_ctx) : unit =
      let used_definitions = Dq.to_list usable_ctx.required
        |> List.map (fun (def : required) -> def.idx) in

      let unused_definitions = Dq.to_list usable_ctx.provided
        |> List.filter (fun (def : provided) -> not (List.mem def.idx used_definitions))
        |> List.map (fun def ->
            let locus = get_locus def.definition
            in
        { locus ; kind = Definition }) in
      redundant <- List.append redundant unused_definitions;

      let unused_facts = Dq.to_list usable_ctx.fact_imports
          |> List.filter (fun import ->
            List.for_all
              (fun expression -> not (List.mem expression used_definitions))
              import.expressions
          )
          |> List.map (fun import ->
            let locus = get_locus import.fact in
            { locus ; kind = Fact }
          )
        in
        dbg "Unused facts - %d" (List.length unused_facts);
        redundant <- List.append redundant unused_facts


    method add_required_def (scx : 's Expr.Visit.scx) (n : int) : unit =
      let size = Dq.size (snd scx) in
      let idx = size - n in
      let references = new hyp_expand#expand scx idx in
      references |> List.iter (unused#mark_used)

    method add_theorem_name scx name =
      match name with
        | None -> scx
        | Some n ->
            let dummy = At false @@ nowhere in
            let theorem_def =
              Defn (Operator (n, dummy) @@ n, Proof Always, Visible, Local) @@ n
            in
            (fst scx, Dq.snoc (snd scx) theorem_def)

  end

class module_visitor (visitor : theorem_visitor) =
  object (_self : 'self)
    inherit Module.Visit.deep_map

    method redundant = visitor#redundant

    method! theorem cx name sq naxs pf orig_pf summ =
      visitor#theorem cx name sq naxs pf orig_pf summ
  end

let find (mule : Module.T.mule) : finding list =
  dbg "walking module %s" mule.core.name.core;
  let v = new module_visitor (new theorem_visitor) in
  let _ = v#tla_module_root mule in
  v#redundant

