type finding_kind = Fact | Definition
type finding = {
  kind: finding_kind;
  locus : Tlapm_lib.Loc.locus;
}

(** Finds redundant facts and definitions *)
val find : Tlapm_lib.Module.T.mule -> finding list
