(** Scans a parsed module and returns LSP
    diagnostics for unused facts and definitoins *)
val find : Tlapm_lib.Module.T.mule -> Lsp.Types.Diagnostic.t list
