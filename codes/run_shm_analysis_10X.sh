#!/usr/bin/env bash
# IgBLAST + Change-O MakeDb for 10x BCR contigs.
# Outputs one folder per sample under results/bcr/shm/.
# Already finished samples are skipped.
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR=$(cd "${SCRIPT_DIR}/.." && pwd)

DATA_DIR="${PROJECT_DIR}/data/cell_ranger_multi"
OUT_ROOT="${PROJECT_DIR}/results/bcr/shm"
LOG_DIR="${OUT_ROOT}/logs"
REF_IGBLAST="/home/han/Documents/reference_genome/igblast"
GERM_DIR="/home/han/Documents/reference_genome/germlines/imgt/human/vdj"
ASSIGN="/home/han/anaconda3/envs/immcantation/bin/AssignGenes.py"
MAKEDB="/home/han/anaconda3/envs/immcantation/bin/MakeDb.py"
NPROC="${NPROC:-8}"
OUT_PREFIX="shm_result"

mkdir -p "${LOG_DIR}"

if [[ ! -x "${ASSIGN}" || ! -x "${MAKEDB}" ]]; then
  echo "AssignGenes.py or MakeDb.py is missing in the immcantation env." >&2
  exit 1
fi

shopt -s nullglob
GERM=("${GERM_DIR}"/imgt_human_IG*.fasta)
shopt -u nullglob
if [[ ${#GERM[@]} -eq 0 ]]; then
  echo "No IMGT germline fasta files in ${GERM_DIR}" >&2
  exit 1
fi

mapfile -t FASTAS < <(find "${DATA_DIR}" -path "*/vdj_b/filtered_contig.fasta" | sort)
if [[ ${#FASTAS[@]} -eq 0 ]]; then
  echo "No filtered_contig.fasta under ${DATA_DIR}" >&2
  exit 1
fi

echo "SHM: ${#FASTAS[@]} samples, ${NPROC} cores, output ${OUT_ROOT}"

for fasta in "${FASTAS[@]}"; do
  sample=$(basename "$(dirname "$(dirname "${fasta}")")")
  contig_dir=$(dirname "${fasta}")
  csv="${contig_dir}/filtered_contig_annotations.csv"
  outdir="${OUT_ROOT}/${sample}"
  pass="${outdir}/${OUT_PREFIX}_db-pass.tsv"
  log="${LOG_DIR}/${sample}.log"

  if [[ ! -f "${csv}" ]]; then
    echo "Missing ${csv}" >&2
    exit 1
  fi
  if [[ -s "${pass}" ]]; then
    echo "skip ${sample}"
    continue
  fi

  mkdir -p "${outdir}"
  echo "IgBLAST ${sample}"
  "${ASSIGN}" igblast \
    -s "${fasta}" \
    -b "${REF_IGBLAST}" \
    --organism human \
    --loci ig \
    --format blast \
    --nproc "${NPROC}" \
    --outdir "${outdir}" \
    --outname "${OUT_PREFIX}" > "${log}" 2>&1

  echo "MakeDb ${sample}"
  "${MAKEDB}" igblast \
    -i "${outdir}/${OUT_PREFIX}_igblast.fmt7" \
    -s "${fasta}" \
    -r "${GERM[@]}" \
    --10x "${csv}" \
    --extended \
    --outdir "${outdir}" \
    --outname "${OUT_PREFIX}" >> "${log}" 2>&1

  if [[ ! -s "${pass}" ]]; then
    echo "MakeDb did not write ${pass}. See ${log}" >&2
    exit 1
  fi
  echo "done ${sample}"
done

echo "SHM databases are in ${OUT_ROOT}"
