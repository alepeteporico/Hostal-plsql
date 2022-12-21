# Proyecto PLSQL sobre un hostal

## Tablas

- Temporadas

| Columna | tipo de dato |
| --- | --- |
| codigo | VARCHAR2 |
| nombre | VARCHAR2 |

- Regímenes

| Columna | tipo de dato |
| --- | --- |
| codigo | VARCHAR2 |
| nombre | VARCHAR2 |

- Tipos de habitación

| Columna | tipo de dato |
| --- | --- |
| codigo | VARCHAR2 |
| nombre | VARCHAR2 |

- Habitaciones

| Columna | tipo de dato |
| --- | --- |
| numero | VARCHAR2 |
| codigotipo | VARCHAR2 |

- Personas

| Columna | tipo de dato |
| --- | --- |
| nif | VARCHAR2 |
| nombre | VARCHAR2 |
| apellidos | VARCHAR2 |
| direccion | VARCHAR2 |
| localidad | VARCHAR2 |

- Estancias

| Columna | tipo de dato |
| --- | --- |
| codigo | VARCHAR2 |
| fecha_inicio | DATE |
| fecha_fin | DATE |
| numerohabitacion | VARCHAR2 |
| nifresponsable | VARCHAR2 |
| nifcliente | VARCHAR2 |
| codigoregimen | VARCHAR2 |

- Tarifas

| Columna | tipo de dato |
| --- | --- |
| codigo | VARCHAR2 |
| codigotipohabitacion | VARCHAR2 |
| codigotemporada | VARCHAR2 |
| codigoregimen | VARCHAR2 |
| preciopordia | VARCHAR2 |

- Facturas

| Columna | tipo de dato |
| --- | --- |
| numero | VARCHAR2 |
| codigoestancia | VARCHAR2 |
| fecha | DATE |

- Gastos Extras

| Columna | tipo de dato |
| --- | --- |
| codigogasto | VARCHAR2 |
| codigoestancia | VARCHAR2 |
| fecha | VARCHAR2 |
| concepto | VARCHAR2 |
| cuantia | NUMBER |

- Actividades

| Columna | tipo de dato |
| --- | --- |
| codigo | VARCHAR2 |
| nombre | VARCHAR2 |
| descripcion | VARCHAR2 |
| precioporpersona | NUMBER |
| comisionhotel | NUMBER |
| costepersonaparahotel | NUMBER |

- Actividades Realizadas

| Columna | tipo de dato |
| --- | --- |
| codigoestancia | VARCHAR2 |
| codigoactividad | VARCHAR2 |
| fecha | DATE |
| numeropersonas | NUMBER |
| abonado | VARCHAR2 |

## Enunciados

1. Realiza una función ComprobarPago que reciba como parámetros un código de cliente y un código de actividad y devuelva un TRUE si el cliente ha pagado la última actividad con ese código que ha realizado y un FALSE en caso contrario. Debes controlar las siguientes excepciones: Cliente inexistente, Actividad Inexistente, Actividad realizada en régimen de Todo Incluido y El cliente nunca ha realizado esa actividad.

    Notas: Si la estancia se ha hecho en régimen de Todo Incluido no se imprimirán los apartados de Gastos Extra o
    Actividades Realizadas. Del mismo modo, si en la estancia no se ha efectuado ninguna Actividad o Gasto Extra, no
    aparecerán en la factura.
    Si una Actividad ha sido abonada in situ tampoco aparecerá en la factura.
    Debes tener cuidado de facturar bien las estancias que abarcan varias temporadas.

2. Realiza un procedimiento llamado ImprimirFactura que reciba un código de estancia e imprima la factura vinculada a la misma. 

3. Realiza un trigger que impida que haga que cuando se inserte la realización de una actividad asociada a una estancia en regimen TI el campo Abonado no pueda valer FALSE.

4. Añade un campo email a los clientes y rellénalo para algunos de ellos. Realiza un trigger que cuando se rellene el campo Fecha de la Factura envíe por correo electrónico un resumen de la factura al cliente, incluyendo los datos fundamentales de la estancia, el importe de cada apartado y el importe total.

5. Añade a la tabla Actividades una columna llamada BalanceHotel. La columna contendrá la cantidad que debe pagar el hotel a la empresa (en cuyo caso tendrá signo positivo) o la empresa al hotel (en cuyo caso tendrá signo negativo) a causa de las Actividades Realizadas por los clientes. Realiza un procedimiento que rellene dicha columna y un trigger que la mantenga actualizada cada vez que la tabla ActividadesRealizadas sufra cualquier cambio.

    Te recuerdo que cada vez que un cliente realiza una actividad, hay dos posibilidades: Si el cliente está en TI el hotel paga a la empresa el coste de la actividad. Si no está en TI, el hotel recibe un porcentaje de comisión del importe que paga el cliente por realizar la actividad.

6. Realiza los módulos de programación necesarios para que una actividad no sea realizada en una fecha concreta por más de 10 personas.

7. Realiza los módulos de programación necesarios para que los precios de un mismo tipo de habitación en una misma temporada crezca en función de los servicios ofrecidos de esta forma: Precio TI > Precio PC > Precio MP> Precio AD.

8. Realiza los módulos de programación necesarios para que un cliente no pueda realizar dos estancias que se solapen en fechas entre ellas, esto es, un cliente no puede comenzar una estancia hasta que no haya terminado la anterior.

## Autores :computer:
* María Jesús Alloza Rodríguez - Secretaria
* Oscar Lucas Leo - Facilitador
* Adrián Palomino García - Portavoz
* Alejandro Gutierrez Valencia - Coordinador
* :school:I.E.S. Gonzalo Nazareno :round_pushpin:(Dos Hermanas, Sevilla).