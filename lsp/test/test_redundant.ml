open Tlapm_lsp_lib
open Analysis.Redundant_usables
open Redundant
open Fmt

let parse filename =
  let path = Filename.concat "resources" filename in
  let content = In_channel.with_open_text path In_channel.input_all in
  match Parser.module_of_string ~content ~filename ~loader_paths:[] with
  | Ok m -> m
  | Error (loc, msg) ->
      Alcotest.failf "parse %s: %s %s"
        filename (Option.value loc ~default:"<no location>") msg

let case filename expected () =
  let actual =
    Redundant.find (parse filename)
    |> List.map (fun finding -> locus_to_string finding.locus)
  in
  Alcotest.(check (list string)) filename expected actual

let cases =
  [
    "SimpleUnused.tla", ["5:28-33"];
    "AssumeNew.tla", [];
    "SimpleUsed.tla", [];
    "AssumeDef.tla", ["6:44-50"];
    "Shadowing.tla", ["4:37"];
    "Equal.tla", [];
    "Parens.tla", [];
    "Bang.tla", [];
    "With.tla", [];
    "If.tla", [];
    "List.tla", [];
    "Let.tla", ["3:37"];
    "Quant.tla", ["3:37"];
    "Choose.tla", [];
    "SetSt.tla", [];
    "SetOf.tla", [];
    "SetEnum.tla", [];
    "Product.tla", [];
    "Tuple.tla", [];
    "Fcn.tla", [];
    "Arrow.tla", [];
    "Rect.tla", [];
    "Record.tla", [];
    "Except.tla", [];
    "Tsub.tla", [];
    "Fair.tla", [];
    "Case.tla", [];
    "Primitives.tla", [];
    "NestedLet.tla", ["3:56"];
    "Lambda.tla", ["3:38"];
    "Assume.tla", [];
    "Step.tla", ["4:22"];
    "StepDef.tla", [];
    "StepRedundant.tla", ["5:23"];
    "Tquant.tla", ["4:43"];
    "Sub.tla", [];
    "ScopedLet.tla", [];
    "StepScopedDef.tla", ["6:22"];
    "StepDefAfterUse.tla", [];
    "ExpandSimple.tla", [];
    "ExpandNested.tla", ["6:31"];
    "MultiTheorem.tla", ["5:21"; "7:21"];
    "Bound.tla", [];
    "DifferentDefinitionFact.tla", ["6:18-21"];
    "UsedFromTheorem.tla", ["6:23"];
    "Inductive.tla", ["12:41-44"];
  ]

let suite =
  cases
  |> List.map (fun (filename, expected) ->
       Alcotest.test_case filename `Quick (case filename expected))

let () = Alcotest.run "redundant" [ "cases", suite ]
