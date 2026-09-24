#!/usr/bin/env bash

set -euo pipefail

ORG="benigaslo"

# Por defecto: DRY RUN
DRY=true

CLEAN_MEMBERS=false
CLEAN_REPOS=false

# ============================================================
# CONFIGURACIÓN
# ============================================================

# Miembros que NO se deben eliminar.
KEEP_MEMBERS=(
  "gerardfp"
  "otro-usuario"
)

# Repositorios que NO se deben eliminar.
KEEP_REPOS=(
  "Erasmus"
  "clickcontrol"
  "docs"
  "docker-postgres"
  "docker-wordpress"
  "disseny"
  "plans"
  "oferta_formativa"
  "bin"
  "_private"
)

# ============================================================
# AYUDA
# ============================================================

usage() {
  cat <<EOF
Uso:
  $0 --org ORGANIZACION [opciones]

Opciones:
  --org ORG          Organización de GitHub
  --clean-members    Eliminar miembros no incluidos en KEEP_MEMBERS
  --clean-repos      Eliminar repositorios no incluidos en KEEP_REPOS
  --no-dry-run       Ejecutar las eliminaciones realmente
  -h, --help         Mostrar esta ayuda

Por defecto se ejecuta en modo DRY RUN.

Los miembros y repositorios que NO se deben eliminar se
especifican directamente en el script, en:

  KEEP_MEMBERS
  KEEP_REPOS

Ejemplos:

  # Simular limpieza de miembros
  $0 --org mi-org --clean-members

  # Ejecutar realmente la limpieza de miembros
  $0 --org mi-org --clean-members --no-dry-run

  # Simular limpieza de repositorios
  $0 --org mi-org --clean-repos

  # Limpiar miembros y repositorios
  $0 --org mi-org --clean-members --clean-repos

  # Ejecutar ambas limpiezas realmente
  $0 --org mi-org --clean-members --clean-repos --no-dry-run
EOF
}

# ============================================================
# ARGUMENTOS
# ============================================================

while [[ $# -gt 0 ]]; do
  case "$1" in

    --org)
      if [[ $# -lt 2 ]]; then
        echo "Error: --org requiere un valor"
        exit 1
      fi

      ORG="$2"
      shift 2
      ;;

    --clean-members)
      CLEAN_MEMBERS=true
      shift
      ;;

    --clean-repos)
      CLEAN_REPOS=true
      shift
      ;;

    --no-dry-run)
      DRY=false
      shift
      ;;

    -h|--help)
      usage
      exit 0
      ;;

    *)
      echo "Error: opción desconocida: $1"
      echo
      usage
      exit 1
      ;;

  esac
done

# ============================================================
# VALIDACIÓN
# ============================================================

if [[ -z "$ORG" ]]; then
  echo "Error: debes especificar --org"
  exit 1
fi

if [[ "$CLEAN_MEMBERS" == false && "$CLEAN_REPOS" == false ]]; then
  echo "Error: debes especificar al menos una operación:"
  echo "  --clean-members"
  echo "  --clean-repos"
  exit 1
fi

# ============================================================
# FUNCIONES
# ============================================================

is_kept_member() {
  local username="$1"

  for keep in "${KEEP_MEMBERS[@]}"; do
    [[ "$username" == "$keep" ]] && return 0
  done

  return 1
}

is_kept_repo() {
  local repo="$1"

  for keep in "${KEEP_REPOS[@]}"; do
    [[ "$repo" == "$keep" ]] && return 0
  done

  return 1
}

# ============================================================
# VARIABLES DE RESULTADO
# ============================================================

REMOVE_MEMBERS=()
KEEPED_MEMBERS=()

REMOVE_REPOS=()
KEEPED_REPOS=()

# ============================================================
# MIEMBROS
# ============================================================

if [[ "$CLEAN_MEMBERS" == true ]]; then

  mapfile -t ALL_MEMBERS < <(
    gh api \
      --paginate \
      "/orgs/$ORG/members" \
      --jq '.[].login'
  )

  for username in "${ALL_MEMBERS[@]}"; do

    if is_kept_member "$username"; then
      KEEPED_MEMBERS+=("$username")
    else
      REMOVE_MEMBERS+=("$username")
    fi

  done

fi

# ============================================================
# REPOSITORIOS
# ============================================================

if [[ "$CLEAN_REPOS" == true ]]; then

  mapfile -t ALL_REPOS < <(
    gh repo list "$ORG" \
      --limit 1000 \
      --json name \
      --jq '.[].name'
  )

  for repo in "${ALL_REPOS[@]}"; do

    if is_kept_repo "$repo"; then
      KEEPED_REPOS+=("$repo")
    else
      REMOVE_REPOS+=("$repo")
    fi

  done

fi

# ============================================================
# RESUMEN
# ============================================================

echo
echo "============================================================"
echo "Organización: $ORG"
echo "============================================================"

if [[ "$DRY" == true ]]; then
  echo "MODO: DRY RUN"
else
  echo "MODO: REAL"
fi

# ------------------------------------------------------------
# Miembros
# ------------------------------------------------------------

if [[ "$CLEAN_MEMBERS" == true ]]; then

  echo
  echo "MIEMBROS:"

  echo -n "  NO SE ELIMINARÁN: "
  if [[ ${#KEEPED_MEMBERS[@]} -gt 0 ]]; then
    printf '%s, ' "${KEEPED_MEMBERS[@]}"
    echo
  else
    echo "(ninguno)"
  fi

  echo -n "  SE ELIMINARÁN:    "
  if [[ ${#REMOVE_MEMBERS[@]} -gt 0 ]]; then
    printf '%s, ' "${REMOVE_MEMBERS[@]}"
    echo
  else
    echo "(ninguno)"
  fi

fi

# ------------------------------------------------------------
# Repositorios
# ------------------------------------------------------------

if [[ "$CLEAN_REPOS" == true ]]; then

  echo
  echo "REPOSITORIOS:"

  echo -n "  NO SE ELIMINARÁN: "
  if [[ ${#KEEPED_REPOS[@]} -gt 0 ]]; then
    printf '%s, ' "${KEEPED_REPOS[@]}"
    echo
  else
    echo "(ninguno)"
  fi

  echo -n "  SE ELIMINARÁN:    "
  if [[ ${#REMOVE_REPOS[@]} -gt 0 ]]; then
    printf '%s, ' "${REMOVE_REPOS[@]}"
    echo
  else
    echo "(ninguno)"
  fi

fi

# ============================================================
# DRY RUN
# ============================================================

if [[ "$DRY" == true ]]; then

  echo
  echo "============================================================"
  echo "DRY RUN: no se realizará ningún cambio."
  echo "============================================================"
  echo

  exit 0
fi

# ============================================================
# CONFIRMACIÓN
# ============================================================

echo
echo "============================================================"
echo "ATENCIÓN"
echo "============================================================"
echo "Se van a realizar las eliminaciones indicadas arriba."
echo "Esta operación puede ser irreversible."
echo

read -r -p "¿Quieres continuar? Escribe 'SI' para confirmar: " CONFIRMATION

if [[ "$CONFIRMATION" != "SI" ]]; then
  echo
  echo "Operación cancelada."
  exit 0
fi

# ============================================================
# ELIMINAR MIEMBROS
# ============================================================

if [[ "$CLEAN_MEMBERS" == true && ${#REMOVE_MEMBERS[@]} -gt 0 ]]; then

  echo
  echo "=== ELIMINANDO MIEMBROS ==="

  for username in "${REMOVE_MEMBERS[@]}"; do

    echo "REMOVE MEMBER: $username"

    gh api \
      --method DELETE \
      "/orgs/$ORG/members/$username"

  done

fi

# ============================================================
# ELIMINAR REPOSITORIOS
# ============================================================

if [[ "$CLEAN_REPOS" == true && ${#REMOVE_REPOS[@]} -gt 0 ]]; then

  echo
  echo "=== ELIMINANDO REPOSITORIOS ==="

  for repo in "${REMOVE_REPOS[@]}"; do

    echo "DELETE REPOSITORY: $repo"

    gh repo delete "$ORG/$repo" --yes

  done

fi

# ============================================================
# FIN
# ============================================================

echo
echo "============================================================"
echo "Finalizado."
echo "============================================================"
