# Debian preseed ISO Builder

Este repositorio lo que logra es, a partir de una imagen ISO de Debian, generar otra pero con un archivo preseed.cfg dentro de la misma, para poder automatizar la instalación y hacerla de forma desatendida.

## Cosas a tener en cuenta

- Se debe tener la imagen ISO en el mismo directorio desde donde se va a ejecutar el script.
- También se debe de tener el fichero `preseed.cfg` en el mismo directorio también.
- En el script hay una variable llamada `ISO` que se encuentra en la línea 9, se debe cambiar el contenido para que sea igual a el nombre de tu imagen ISO.
