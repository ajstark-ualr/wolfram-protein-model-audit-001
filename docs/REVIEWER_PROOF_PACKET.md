# Artifact 001 — 90-Second Reviewer Proof Packet

## Auditing Protein-Dynamics Models with Structural Nulls

**What it is:**  
A reproducible Wolfram Language reconstruction and audit of a homology-aware protein-dynamics benchmark from frozen experimental outputs.

## Scientific question

Does adding static contact-graph information improve residue-level protein-dynamics prediction beyond an angular-only structural baseline when performance is evaluated across homology-aware ECOD H-groups?

## Frozen evaluation set

- 2,000 held-out residue predictions
- 100 proteins
- 20 sampled residues per protein
- 59 ECOD H-groups
- 5 H-group-disjoint folds

## Primary result

| Model | Macro-H Spearman rho |
|---|---:|
| Angular-only A | 0.1142984580 |
| Graph-enhanced C | 0.3366254620 |

**Primary contrast:** C − A = **+0.2223270040**

**95% H-group bootstrap CI:** **[+0.1625783739, +0.2836233592]**

The interval remains above zero.

## Validation

- Wolfram reconstruction matches the persisted Phase-4A authority to machine precision.
- All six structural null controls satisfy `|rho| < 0.1`.
- Frozen input SHA256 is verified before analysis.
- Notebook uses relative artifact paths rather than machine-specific absolute paths.
- Clean-kernel notebook reconstruction was previously verified.
- Release verifier passes.
- v1.0.0 release checksum manifest passes.
- Frozen release archive created successfully.

## What the Wolfram artifact adds

- Independent Wolfram Language reconstruction of the reported metric from persisted outputs
- Per-protein and homology-aware Macro-H aggregation
- Authority verification
- Structural-null audit
- H-group performance visualization
- Bootstrap uncertainty summary
- Interactive ECOD H-group explorer
- Embedded provenance and frozen-input integrity checks

## Claim boundaries

This artifact reconstructs frozen experimental outputs; it does **not** retrain the underlying models and is **not** an independent experimental replication.

The result supports model C over model A under the reported homology-aware evaluation. It does not establish superiority over every alternative representation: pLDDT achieves a similar Macro-H score.

No quantum-advantage claim is made.

## Reproducibility authority

Canonical run: `run_20260824T154329Z`

Run commit: `44945311f38bcdeb7b45be911fc8432bcc275d79`

Frozen input SHA256:

`3a42e891ebf54e141544b675ee5c113842bda57cef6212b89942aea4ace04d26`

Canonical notebook SHA256:

`30493ddec9a7bb796c6f06b3bbc172bfdd46b78e7360d6746297ba0f99709318`

Frozen v1.0.0 archive SHA256:

`39002686a9409d0160de8511075889656af0721d81c4e8b924cfb5a233771576`

## Reviewer path

1. Read this page.
2. Open the H-group scatter.
3. Open `protein_model_audit_final.nb`.
4. Inspect the authority-validation and structural-null sections.
5. Run `./verify_artifact.sh`.
6. Run `sha256sum -c MANIFEST.sha256`.

A technically informed reviewer should be able to understand the question, result, validation strategy, limitations, and reproducibility posture in under two minutes before opening the full notebook.
