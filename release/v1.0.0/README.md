# Auditing Protein-Dynamics Models with Structural Nulls

Reproducible Wolfram Language reconstruction of a homology-aware
protein-dynamics benchmark from frozen experimental outputs.

## Result

- Residues: 2000
- Proteins: 100
- ECOD H-groups: 59
- Macro-H A: 0.1142984580
- Macro-H C: 0.3366254620
- C - A: +0.2223270040
- 95% bootstrap CI: [+0.1625783739, +0.2836233592]
- Authority reconstruction: PASS
- Six structural null controls: PASS

## Scope

This artifact reconstructs persisted predictions and statistics.
It does not retrain models and is not an independent experimental replication.
The C-over-A result does not establish superiority over every alternative
baseline; pLDDT achieves a similar Macro-H score.

## Run

Requires Mathematica 15.0.1 on Linux x86-64.

Open `protein_model_audit_final.nb`, quit the local kernel, and evaluate the
notebook from the top.

## Verify

Run:

    ./verify_artifact.sh
    sha256sum -c MANIFEST.sha256

Frozen input SHA256:

    3a42e891ebf54e141544b675ee5c113842bda57cef6212b89942aea4ace04d26

Canonical run:

    run_20260824T154329Z

Run commit:

    44945311f38bcdeb7b45be911fc8432bcc275d79
