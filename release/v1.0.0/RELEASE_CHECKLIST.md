# Artifact 001 — v1.0.0 Release Checklist

## Automated release gate

- [ ] `./verify_artifact.sh` exits 0.
- [ ] Required release files are present and non-empty.
- [ ] Frozen scientific file SHA256 values match authority.
- [ ] `ARTIFACT_MANIFEST.json` is valid JSON.
- [ ] Manifest authority fields match the frozen result.
- [ ] Final notebook contains no machine-specific `/home/adam/` path.
- [ ] Known stale failure markers are absent.

## Mathematica reproducibility gate

From a fresh local kernel, evaluate `protein_model_audit_final.nb` from the top.

Confirm:

- [ ] Residue rows = 2000.
- [ ] Proteins = 100.
- [ ] ECOD H-groups = 59.
- [ ] Macro-H A ≈ 0.1142984580.
- [ ] Macro-H C ≈ 0.3366254620.
- [ ] C - A ≈ +0.2223270040.
- [ ] 95% H-group bootstrap CI = [+0.1625783739, +0.2836233592].
- [ ] Authority validation = PASS / True.
- [ ] Structural-null validation = PASS / True.
- [ ] Frozen-input SHA256 match = True.
- [ ] Interactive H-group explorer updates correctly.

## Scientific claim gate

- [ ] Describe this as a Wolfram-language reconstruction from frozen persisted outputs.
- [ ] Do not call it an independent experimental replication.
- [ ] Do not claim superiority over every alternative baseline.
- [ ] Keep the pLDDT limitation visible.
- [ ] Make no quantum-advantage claim.

## Freeze gate

- [ ] `MANIFEST.sha256` generated from the final release contents.
- [ ] `sha256sum -c MANIFEST.sha256` passes.
- [ ] Final archive created only after all checks above pass.
- [ ] Archive SHA256 recorded alongside the archive.
- [ ] No files inside `v1.0.0/` are changed after the checksum freeze without regenerating the manifest and archive.

## Release identity

- Artifact: `wolfram-protein-model-audit-001`
- Version: `1.0.0`
- Canonical run: `run_20260824T154329Z`
- Run commit: `44945311f38bcdeb7b45be911fc8432bcc275d79`
