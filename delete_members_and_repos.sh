#!/usr/bin/env bash

set -euo pipefail

ORG=""
DRY=false
MEMBERS_FILE=""
KEEP_REPOS=()

usage() {
  cat <<EOF
Uso:
  $0 --org ORGANIZACION [opciones]

Opciones:
  --org ORG              Organización de GitHub
  --members FILE         Archivo con usernames, uno por línea, para eliminar
  --keep REPO            Repositorio que NO se debe eliminar (se puede repetir)
  --dry                  Simular los cambios, sin eliminar nada
  -h, --help             Mostrar esta ayuda

Ejemplos:

  # Eliminar miembros
  $0 --org mi-org --members members.txt

  # Eliminar repositorios excepto los indicados
  $0 --org mi-org --keep repo-a --keep repo-b

  # Simular ambas operaciones
  $0 --org mi-org --members members.txt \
     --keep repo-a --keep repo-b --dry
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --org)
      ORG="$2"
      shift 2
      ;;
    --members)
      MEMBERS_FILE="$2"
      shift 2
      ;;
    --keep)
      KEEP_REPOS+=("$2")
      shift 2
      ;;
    --dry)
      DRY=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Opción desconocida: $1"
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$ORG" ]]; then
  echo "Error: debes especificar --org"
  exit 1
fi

if [[ "$DRY" == true ]]; then
  echo "=== DRY RUN: no se realizará ningún cambio ==="
else
  echo "=== MODO REAL: se realizarán eliminaciones ==="
fi

is_kept() {
  local repo="$1"

  for keep in "${KEEP_REPOS[@]}"; do
    [[ "$repo" == "$keep" ]] && return 0
  done

  return 1
}

# ------------------------------------------------------------
# Miembros
# ------------------------------------------------------------

if [[ -n "$MEMBERS_FILE" ]]; then

  if [[ ! -f "$MEMBERS_FILE" ]]; then
    echo "Error: no existe el archivo $MEMBERS_FILE"
    exit 1
  fi

  echo
  echo "=== MIEMBROS ==="

  while IFS= read -r username || [[ -n "$username" ]]; do

    # Ignorar líneas vacías y comentarios
    [[ -z "$username" ]] && continue
    [[ "$username" =~ ^[[:space:]]*# ]] && continue

    if [[ "$DRY" == true ]]; then
      echo "WOULD REMOVE MEMBER: $username"
    else
      echo "REMOVE MEMBER: $username"

      gh api \
        --method DELETE \
        "/orgs/$ORG/members/$username"
    fi

  done < "$MEMBERS_FILE"
fi

# ------------------------------------------------------------
# Repositorios
# ------------------------------------------------------------

if [[ ${#KEEP_REPOS[@]} -gt 0 || "$DRY" == true ]]; then

  echo
  echo "=== REPOSITORIOS ==="

  gh repo list "$ORG" \
    --limit 1000 \
    --json name \
    --jq '.[].name' |
  while IFS= read -r repo; do

    if is_kept "$repo"; then
      echo "KEEP: $repo"
      continue
    fi

    if [[ "$DRY" == true ]]; then
      echo "WOULD DELETE: $repo"
    else
      echo "DELETE: $repo"

      gh repo delete "$ORG/$repo" --yes
    fi

  done
fi

echo
echo "Finalizado."
