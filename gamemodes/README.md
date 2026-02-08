# _Acerca del sistema_

La versión `HouseX` del sistema de GameMode es la misma que la de Filterscript `HouseX`, la única diferencia está en los nombres de las funciones principales:

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

## _Aclaración:_

* Para garantizar que todo funcione correctamente y no existan inconvenientes como IDs duplicados.

* Textdraws que no aparecen o diálogos reemplazados o demás errores usaremos directamente el Gamemode.

* En caso de que use un Gamemode RP/FR/TDM/etc lo más recomendable es migrar todo el sistema del FS directamente a su GameMode.
