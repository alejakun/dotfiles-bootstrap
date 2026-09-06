# dotfiles-bootstrap — movido

Este repositorio se fusionó en **[alejakun/bootstrap](https://github.com/alejakun/bootstrap)**
el 2026-09-05, junto con `dotfiles-win`. Su historia completa se conserva allá,
bajo `macos/`.

## Arranque de una Mac

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/alejakun/bootstrap/master/macos/bootstrap.sh)
```

## Por qué esto no se borró

Los dos repositorios hacían el mismo trabajo para plataformas distintas y
estaban separados por accidente histórico. Al fusionarlos, las dos
implementaciones del registro de llave SSH quedan una carpeta al lado de la otra
—que es la única mitigación posible para una duplicación que no se puede
eliminar— y los nombres pasan a describir la función en vez de la plataforma.

`bin/bootstrap.sh` sigue aquí, pero solo imprime la dirección nueva y sale con
error. Un repositorio archivado sigue siendo legible: si el script antiguo se
hubiera dejado intacto, el one-liner viejo seguiría funcionando y correría la
versión que clonaba por HTTPS **sin registrar llave SSH**. Una máquina arrancada
así no puede aprovisionar el homelab, y lo haría reportando éxito en cada
corrida.
