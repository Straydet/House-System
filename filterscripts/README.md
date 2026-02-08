# Acerca del sistema

La versión `HouseX` del sistema de Filterscript es la misma que la de Gamemode `HouseX`, la única diferencia está en los nombres de las funciones principales:

En el Gamemode:
```pawn
public OnGameModeInit()
public OnGameModeExit()
```

Mientras que en el Filterscript se usan:

```pawn
public OnFilterScriptInit()
public OnFilterScriptExit()
```


## Aclaración:

Los filterscript's suelen presentar fallos o conflictos al conectarse con un gamemode, principalmente porque ambos comparten el mismo entorno de ejecución.

Esto significa que si existen variables, enums, funciones o IDs repetidos, el servidor no distingue cuál debe usar y termina reemplazando uno por otro.

* Para evitar estos problemas, lo más recomendable es migrar todo el sistema del FS directamente al GM.

* En caso de que sea necesario mantener funciones o stocks del FS, es fundamental cambiarles el nombre para que no se choquen ni se solapen con los del GM.




# Ejemplos de conflictos/errores comunes


### _Diálogos erróneos_:  

_Si el FS y el GM usan el mismo ID de diálogo (ejemplo: ShowPlayerDialog(playerid, 1, ...)), el último que se ejecute sobrescribe al anterior._

_Por eso puede aparecer un diálogo del FS en lugar del que corresponde al GM._

## _Textdraws:_  

_Los textdraws globales (visibles para todos los jugadores) suelen mostrarse sin problema desde un FS._

_Sin embargo, los player textdraws (individuales por jugador) no se muestran correctamente si provienen de un FS, porque la gestión de textdraws está más integrada en el GM y tiene prioridad sobre los FS._


## _Enums y variables:_

_Cuando un FS define enums o variables con los mismos nombres que el GM, se generan conflictos._

_El compilador puede aceptar ambos, pero en tiempo de ejecución/en el juego se producen errores o comportamientos inesperados porque las referencias se solapan._


## _Stocks y funciones duplicadas:_
 
_Si tanto el FS como el GM tienen un stock o función con el mismo nombre, el compilador no sabe cuál usar._

_Esto puede causar que el FS “pise” la lógica del GM o viceversa en el juego._


## _Soluciones / Cómo evitar estos problemas_

_Usar IDs únicos para diálogos y textdraws en cada FS._

_Definir nombres distintos para variables, enums, funciones en los FS, evitando repetir los del GM y viceversa._

_Considerar que los FS son complementos y no deben replicar la lógica principal del GM._


_Cuando se requiera un sistema complejo (textdraws dinámicos, diálogos personalizados, etc.), es más seguro implementarlo directamente en el GM en lugar de un FS._
