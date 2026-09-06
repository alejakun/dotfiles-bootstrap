#!/bin/bash
# ================================================================================
# Este repositorio se fusionó en alejakun/bootstrap el 2026-09-05.
# ================================================================================
# Su historia completa vive allá, bajo macos/. Aqui no queda codigo que ejecutar.
#
# Este archivo NO se borro ni se dejo funcionando a proposito. Un repositorio
# archivado sigue siendo legible, asi que el one-liner viejo seguiria
# descargandose y CORRERIA la version anterior: la que clonaba por HTTPS y no
# registraba llave SSH. Una maquina arrancada asi no puede aprovisionar el
# homelab, y lo haria reportando exito. Fallar aqui con la direccion nueva es
# mejor que acertar en silencio con la equivocada.

RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'

echo ""
echo -e "${RED}Este bootstrap se movió.${NC}"
echo ""
echo "Usa:"
echo -e "  ${CYAN}bash <(curl -fsSL https://raw.githubusercontent.com/alejakun/bootstrap/master/macos/bootstrap.sh)${NC}"
echo ""
echo "El repositorio nuevo lleva las dos plataformas, macOS y Windows:"
echo "  https://github.com/alejakun/bootstrap"
echo ""
exit 1
