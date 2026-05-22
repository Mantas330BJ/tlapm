module LspT = Lsp.Types

let finding_to_diagnostic (f : Redundant.finding) : LspT.Diagnostic.t =
  let range = Range.as_lsp_range (Range.of_locus_must f.locus) in
  let message =
    match f.kind with
    | Redundant.Definition -> "Unused definition"
    | Redundant.Fact -> "Unused fact"
  in
  LspT.Diagnostic.create ~range
    ~message:(`String message)
    ~severity:LspT.DiagnosticSeverity.Warning
    ~tags:[ LspT.DiagnosticTag.Unnecessary ]
    ~source:"tlapm" ()

let find (mule : Tlapm_lib.Module.T.mule) : LspT.Diagnostic.t list =
  Redundant.find mule |> List.map finding_to_diagnostic
