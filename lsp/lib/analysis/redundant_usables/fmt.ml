open Tlapm_lib.Util
open Tlapm_lib
open Tlapm_lib.Proof.T
open Tlapm_lib.Expr.T
module Dq = Deque
open Property

let verbose = false

let dbg fmt =
  if verbose then Printf.printf (fmt ^^ "\n%!")
  else Printf.ifprintf stdout (fmt ^^ "\n%!")

let rec dbg_cx (scx : 's Expr.Visit.scx) =
  let _, cx = scx in
  dbg "  --- cx (size %d) ---" (Dq.size cx);
  Dq.iter (fun i h -> dbg "  cx[%d] = %s" i (str_of_hyp h)) cx
and str_of_hyp (h : Expr.T.hyp) =
  match h.core with
  | Flex n -> Printf.sprintf "Flex %s" n.core
  | Fresh (n, _, _, _) -> Printf.sprintf "Fresh %s" n.core
  | FreshTuply _ -> "FreshTuply"
  | Defn (df, _, _, _) ->
      (match df.core with
       | Operator (n, _) -> Printf.sprintf "Defn Operator %s" n.core
       | Bpragma (n, _, _) -> Printf.sprintf "Defn Bpragma %s" n.core
       | Instance (n, _) -> Printf.sprintf "Defn Instance %s" n.core
       | Recursive (n, _) -> Printf.sprintf "Defn Recursive %s" n.core)
  | Fact (expr, _, _) -> Printf.sprintf "Fact - %s" (expr_to_string expr)
and expr_to_string e = Expr.Fmt.string_of_expr Deque.empty e

let expr_to_name (e : expr) =
  match e.core with
  | Ix _ -> "Ix"
  | Opaque _ -> "Opaque"
  | Internal _ -> "Internal"
  | Lambda _ -> "Lambda"
  | Sequent _ -> "Sequent"
  | Bang _ -> "Bang"
  | Apply _ -> "Apply"
  | With _ -> "With"
  | If _ -> "If"
  | List _ -> "List"
  | Let _ -> "Let"
  | Quant _ -> "Quant"
  | QuantTuply _ -> "QuantTuply"
  | Tquant _ -> "Tquant"
  | Choose _ -> "Choose"
  | ChooseTuply _ -> "ChooseTuply"
  | SetSt _ -> "SetSt"
  | SetStTuply _ -> "SetStTuply"
  | SetOf _ -> "SetOf"
  | SetOfTuply _ -> "SetOfTuply"
  | SetEnum _ -> "SetEnum"
  | Product _ -> "Product"
  | Tuple _ -> "Tuple"
  | Fcn _ -> "Fcn"
  | FcnTuply _ -> "FcnTuply"
  | FcnApp _ -> "FcnApp"
  | Arrow _ -> "Arrow"
  | Rect _ -> "Rect"
  | Record _ -> "Record"
  | Except _ -> "Except"
  | Dot _ -> "Dot"
  | Sub _ -> "Sub"
  | Tsub _ -> "Tsub"
  | Fair _ -> "Fair"
  | Case _ -> "Case"
  | String _ -> "String"
  | Num _ -> "Num"
  | At _ -> "At"
  | Parens _ -> "Parens"

let locus_to_string locus =
  Format.asprintf "%a" Loc.pp_locus_compact locus

type provided = {
  idx : int;
  mutable definition : use_def wrapped;
}

type required = {
  idx : int;
}

type fact_import = {
  fact : expr;
  expressions : int list
}

type usable_ctx = {
  mutable provided : provided Dq.dq;
  mutable required : required Dq.dq;
  mutable fact_imports : fact_import Dq.dq;
}

let pp_provided lst =
  dbg "provided [%d]:" (Dq.size lst.provided);
  Dq.to_list lst.provided
    |> List.map (fun (p : provided) -> string_of_int p.idx)
    |> String.concat ", "
    |> dbg "Provided - '%s'";
  Dq.to_list lst.required
    |> List.map (fun (r : required) -> string_of_int r.idx)
    |> String.concat ", "
    |> dbg "Required - '%s'";

  dbg "Facts [%d]" (Dq.size lst.fact_imports);
  Dq.iter (fun _ f -> dbg "Fact %s" (expr_to_string f.fact)) lst.fact_imports
