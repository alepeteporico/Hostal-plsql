CREATE TABLE temporadas(
	codigo VARCHAR(9),
	Nombre VARCHAR(35),
	CONSTRAINT pk_temporadas PRIMARY KEY (codigo)
);

CREATE TABLE regimenes(
	codigo			VARCHAR(9),
	Nombre			VARCHAR(35),
	CONSTRAINT pk_regimenes PRIMARY KEY (codigo),
	CONSTRAINT contenido_codigo CHECK( codigo IN ('AD','MP','PC','TI'))
);

CREATE TABLE tipos_de_habitacion(
	codigo			VARCHAR(9),
	nombre			VARCHAR(35),
	CONSTRAINT pk_tipohabit PRIMARY KEY (codigo)
);

CREATE TABLE habitaciones(
	numero			VARCHAR(4),
	codigotipo		VARCHAR(9),
	CONSTRAINT pk_habitaciones PRIMARY KEY (numero),
	CONSTRAINT fk_habitaciones FOREIGN KEY (codigotipo) REFERENCES tipos_de_habitacion(codigo)
);

CREATE TABLE personas(
	nif VARCHAR(9),
	nombre VARCHAR(35) CONSTRAINT nombre_obligatorio NOT NULL,
	apellidos VARCHAR(35) CONSTRAINT apellidos_obligatorio NOT NULL,
	direccion VARCHAR(150) CONSTRAINT direccion_obligatorio NOT NULL,
	localidad VARCHAR(35) CONSTRAINT localidad_obligatorio NOT NULL,
	CONSTRAINT pk_personas PRIMARY KEY (nif),
	CONSTRAINT nif_valido CHECK( nif ~ '[0-9]{8}[A-Z]{1}' OR nif ~ '[K,L,M,X,Y,Z]{1}[0-9]{7}[A-Z]{1}'),
  	CONSTRAINT localidades CHECK( localidad LIKE '%(Salamanca)' OR localidad LIKE '%(Avila)' OR localidad LIKE '%(Madrid)')
);

CREATE TABLE estancias (
	codigo VARCHAR(9),
	fecha_inicio DATE,
	fecha_fin DATE,
	numerohabitacion VARCHAR(9),
	nifresponsable VARCHAR(9),
	nifcliente VARCHAR(9),
	codigoregimen VARCHAR(9),
	CONSTRAINT pk_estancias PRIMARY KEY (codigo),
	CONSTRAINT unica_estancia unique (nifresponsable),
	CONSTRAINT fk_estanciasnumhab FOREIGN KEY (numerohabitacion) REFERENCES habitaciones(numero),
	CONSTRAINT fk_estanciasnifresp FOREIGN KEY (nifresponsable) REFERENCES personas(nif),
	CONSTRAINT fk_estanciasnifcli FOREIGN KEY (nifcliente) REFERENCES personas(nif),
	CONSTRAINT fk_estanciasregim FOREIGN KEY (codigoregimen) REFERENCES regimenes(codigo),
	CONSTRAINT fecha_salida CHECK(to_char(fecha_fIN,'hh24:mi')<='21:00')
);

CREATE TABLE tarifas(
	codigo VARCHAR(9),
	codigotipohabitacion VARCHAR(9),
	codigotempORada	VARCHAR(9),
	codigoregimen VARCHAR(9),
	preciopordia DECIMAL(6,2),
	CONSTRAINT pk_tarifas PRIMARY KEY (codigo),
	CONSTRAINT fk_tarifastipo FOREIGN KEY (codigotipohabitacion) REFERENCES tipos_de_habitacion(codigo),
	CONSTRAINT fk_tarifasregimenes FOREIGN KEY (codigoregimen) REFERENCES regimenes(codigo),
	CONSTRAINT fk_tarifastempOR FOREIGN KEY (codigotemporada) REFERENCES temporadas(codigo)
);

CREATE TABLE facturas (
    numero VARCHAR(9),
	codigoestancia VARCHAR(9),
	fecha DATE,
	CONSTRAINT pk_facturas PRIMARY KEY (numero),
	CONSTRAINT fk_facturas FOREIGN KEY (codigoestancia) REFERENCES estancias (codigo)
);

CREATE TABLE gastos_extras (
	codigogasto	VARCHAR(9),
	codigoestancia VARCHAR(9),
	fecha DATE,
	concepto VARCHAR(120),
	cuantia	DECIMAL(6,2),
	CONSTRAINT pk_gastext PRIMARY KEY (codigogasto),
	CONSTRAINT fk_gastext FOREIGN KEY (codigoestancia) REFERENCES estancias(codigo)
);

CREATE TABLE actividades (
	codigo VARCHAR(9),
	nombre VARCHAR(35),
	descripcion	VARCHAR(140),
	precioporpersona DECIMAL(6,2),
	comisionhotel DECIMAL(6,2),
	costepersonaparahotel DECIMAL(6,2),
	CONSTRAINT pk_actividades PRIMARY KEY (codigo),
	CONSTRAINT codigo_valido CHECK(codigo ~ '[A-Z]{1}[0-9]{3}.*'),
	CONSTRAINT comisionhotel_inferiOR CHECK(comisionhotel <= precioporpersona*0.25)
);

CREATE TABLE actividadesrealizadas (
	codigoestancia VARCHAR(9),
	codigoactividad	VARCHAR(9),
	fecha DATE,
	numpersonas	DECIMAL(6,2) DEFAULT 1,
	abonado	VARCHAR (1) DEFAULT 'N',
	CONSTRAINT pk_actrealizadas PRIMARY KEY (codigoestancia, codigoactividad, fecha),
	CONSTRAINT fk_actrealestan FOREIGN KEY (codigoestancia) REFERENCES estancias(codigo),
	CONSTRAINT fk_actrealact FOREIGN KEY (codigoactividad) REFERENCES actividades(codigo),
  	CONSTRAINT descanso_activs CHECK(to_char(fecha,'DAY') NOT LIKE '%MON%' and to_char(fecha,'hh24:mi') NOT BETWEEN '23:00' and '05:00')
);

----------------------------------------------------------------------------------------
---INSERCIÓN DE DATOS
----------------------------------------------------------------------------------------


---Temporadas -- codigo, nombre
INSERT INTO temporadas VALUES ('01','Baja');
INSERT INTO temporadas VALUES ('02','Alta');
INSERT INTO temporadas VALUES ('03','Especial');


---Regimenes -- codigo, nombre
INSERT INTO regimenes VALUES ('AD','Alojamiento y Desayuno');
INSERT INTO regimenes VALUES ('MP','Media pension');
INSERT INTO regimenes VALUES ('PC','Pension completa');
INSERT INTO regimenes VALUES ('TI','Todo INcluido');


---Tipos de habitacion -- codigo, nombre
INSERT INTO tipos_de_habitacion VALUES ('01','Habitacion INdividual');
INSERT INTO tipos_de_habitacion VALUES ('02','Habitacion doble');
INSERT INTO tipos_de_habitacion VALUES ('03','Habitacion triple');

---Habitaciones -- numero, codigotipo
INSERT INTO habitaciones VALUES ('00','01');
INSERT INTO habitaciones VALUES ('01','02');
INSERT INTO habitaciones VALUES ('02','03');
INSERT INTO habitaciones VALUES ('03','01');
INSERT INTO habitaciones VALUES ('04','02');
INSERT INTO habitaciones VALUES ('05','02');
INSERT INTO habitaciones VALUES ('06','02');
INSERT INTO habitaciones VALUES ('07','02');
INSERT INTO habitaciones VALUES ('08','03');
INSERT INTO habitaciones VALUES ('09','02');
INSERT INTO habitaciones VALUES ('10','01');
INSERT INTO habitaciones VALUES ('11','03');

---Personas -- nif, nombre, apellidos, direccion, localidad
INSERT INTO personas VALUES ('54890865P','Alvaro','Rodriguez Marquez','C\ Alemania n 19','Madrid (Madrid)');
INSERT INTO personas VALUES ('40687067K','Aitor','Leon Delgado','Ciudad Blanca Blq 16 1-D','Adanero (Avila)');
INSERT INTO personas VALUES ('77399071T','Virginia','Leon Delgado','Ciudad Blanca Blq 16 1-D','Muiopepe (Avila)');
INSERT INTO personas VALUES ('69191424H','Antonio Agustin','Fernandez Melendez','C\Armero n 19','Muñico (Avila)');
INSERT INTO personas VALUES ('36059752F','Antonio','Melendez Delgado','C\Armero n 18','Navadijos (Avila)');
INSERT INTO personas VALUES ('10402498N','Carlos','Mejias Calatrava','C\ Francisco de Rioja n 9','Abusejo (Salamanca)');
INSERT INTO personas VALUES ('10950967T','Ana','Gutierrez Bando','C\ Burgos n 3','Alaraz (Salamanca)');
INSERT INTO personas VALUES ('88095695Z','Adrian','Garcia Guerra','C\ Nueva n 14','Mozarbez (Salamanca)');
INSERT INTO personas VALUES ('95327640T','Juan Carlos','Romero Diaz','C\ San LORenzo n 22','Ajalvir (Madrid)');
INSERT INTO personas VALUES ('06852683V','Francisco','Franco Giraldez','AAVV Rosales n 1','Leganes (Madrid)');


---Estancias -- codigo, fecha inicio, fecha fin, numerohabitacion, nifresponsable, nifcliente, codigoregimen
INSERT INTO estancias VALUES ('00',to_DATE('11-03-2016 12:00','DD-MM-YYYY hh24:mi'),to_DATE('13-03-2016 12:00','DD-MM-YYYY hh24:mi'),'00','54890865P','54890865P','AD');
INSERT INTO estancias VALUES ('01',to_DATE('19-05-2015 17:00','DD-MM-YYYY hh24:mi'),to_DATE('25-05-2015 17:00','DD-MM-YYYY hh24:mi'),'10','10950967T','10950967T','MP');
INSERT INTO estancias VALUES ('02',to_DATE('20-09-2015 13:30','DD-MM-YYYY hh24:mi'),to_DATE('21-09-2015 13:30','DD-MM-YYYY hh24:mi'),'03','10402498N','10402498N','AD');
INSERT INTO estancias VALUES ('03',to_DATE('14-03-2015 11:15','DD-MM-YYYY hh24:mi'),to_DATE('16-03-2015 11:15','DD-MM-YYYY hh24:mi'),'02','95327640T','95327640T','MP');
INSERT INTO estancias VALUES ('04',to_DATE('30-07-2015 18:00','DD-MM-YYYY hh24:mi'),to_DATE('11-08-2015 18:00','DD-MM-YYYY hh24:mi'),'09','06852683V','06852683V','TI');
INSERT INTO estancias VALUES ('05',to_DATE('09-01-2016 16:35','DD-MM-YYYY hh24:mi'),to_DATE('12-01-2015 16:35','DD-MM-YYYY hh24:mi'),'05','40687067K','40687067K','MP');
INSERT INTO estancias VALUES ('06',to_DATE('26-12-2015 19:50','DD-MM-YYYY hh24:mi'),to_DATE('01-01-2016 19:50','DD-MM-YYYY hh24:mi'),'07','77399071T','77399071T','PC');
INSERT INTO estancias VALUES ('07',to_DATE('22-02-2016 20:20','DD-MM-YYYY hh24:mi'),to_DATE('29-02-2016 20:20','DD-MM-YYYY hh24:mi'),'04','69191424H','69191424H','PC');


---Tarifas -- codigo, codigotipohabitacion, codigotemporada, codigoregimen, preciopordia
INSERT INTO tarifas VALUES ('00','01','01','AD',50);
INSERT INTO tarifas VALUES ('00','01','01','AD',50);
INSERT INTO tarifas VALUES ('01','01','02','AD',70);
INSERT INTO tarifas VALUES ('02','01','03','AD',60);
INSERT INTO tarifas VALUES ('03','02','01','AD',60);
INSERT INTO tarifas VALUES ('04','02','02','AD',84);
INSERT INTO tarifas VALUES ('05','02','03','AD',72);
INSERT INTO tarifas VALUES ('06','03','01','AD',81);
INSERT INTO tarifas VALUES ('07','03','02','AD',115);
INSERT INTO tarifas VALUES ('08','03','03','AD',100);
INSERT INTO tarifas VALUES ('09','01','01','MP',35);
INSERT INTO tarifas VALUES ('10','01','02','MP',50);
INSERT INTO tarifas VALUES ('11','01','03','MP',40);
INSERT INTO tarifas VALUES ('12','02','01','MP',79);
INSERT INTO tarifas VALUES ('13','02','02','MP',119);
INSERT INTO tarifas VALUES ('14','02','03','MP',70);
INSERT INTO tarifas VALUES ('15','03','01','MP',43);
INSERT INTO tarifas VALUES ('16','03','02','MP',65);
INSERT INTO tarifas VALUES ('17','03','03','MP',52.5);
INSERT INTO tarifas VALUES ('18','01','01','PC',85);
INSERT INTO tarifas VALUES ('19','01','02','PC',102);
INSERT INTO tarifas VALUES ('20','01','03','PC',92.9);
INSERT INTO tarifas VALUES ('21','02','01','PC',80.5);
INSERT INTO tarifas VALUES ('22','02','02','PC',105.6);
INSERT INTO tarifas VALUES ('23','02','03','PC',93.5);
INSERT INTO tarifas VALUES ('24','03','01','PC',61.6);
INSERT INTO tarifas VALUES ('25','03','02','PC',110);
INSERT INTO tarifas VALUES ('26','03','03','PC',94.1);
INSERT INTO tarifas VALUES ('27','01','01','TI',79);
INSERT INTO tarifas VALUES ('28','01','02','TI',99);
INSERT INTO tarifas VALUES ('29','01','03','TI',86);
INSERT INTO tarifas VALUES ('30','02','01','TI',60);
INSERT INTO tarifas VALUES ('31','02','02','TI',95);
INSERT INTO tarifas VALUES ('32','02','03','TI',80);
INSERT INTO tarifas VALUES ('33','03','01','TI',60);
INSERT INTO tarifas VALUES ('34','03','02','TI',87);
INSERT INTO tarifas VALUES ('35','03','03','TI',70);


---Facturas -- numero, codigoestancia, fecha
INSERT INTO facturas VALUES ('00','00',to_DATE('13-03-2016 12:00','DD-MM-YYYY hh24:mi'));
INSERT INTO facturas VALUES ('01','02',to_DATE('21-09-2015 13:30','DD-MM-YYYY hh24:mi'));
INSERT INTO facturas VALUES ('02','04',to_DATE('11-08-2015 18:00','DD-MM-YYYY hh24:mi'));
INSERT INTO facturas VALUES ('03','07',to_DATE('29-02-2016 20:20','DD-MM-YYYY hh24:mi'));
INSERT INTO facturas VALUES ('04','05',to_DATE('12-01-2015 16:35','DD-MM-YYYY hh24:mi'));
INSERT INTO facturas VALUES ('05','01',to_DATE('25-05-2015 17:00','DD-MM-YYYY hh24:mi'));


---Gastos Extras -- codigogasto, codigoestancia, fecha, concepto, cuantia
INSERT INTO gastos_extras VALUES ('00','03',to_DATE('15-03-2015 18:23','DD-MM-YYYY hh24:mi'),'Bolos',7);
INSERT INTO gastos_extras VALUES ('01','02',to_DATE('20-09-2015 19:15','DD-MM-YYYY hh24:mi'),'Centro de pasatiempo de mascotas',12);
INSERT INTO gastos_extras VALUES ('02','01',to_DATE('23-05-2015 12:40','DD-MM-YYYY hh24:mi'),'Piscina privada',2);
INSERT INTO gastos_extras VALUES ('03','01',to_DATE('23-05-2015 17:50','DD-MM-YYYY hh24:mi'),'Wifi',2);
INSERT INTO gastos_extras VALUES ('04','03',to_DATE('15-03-2015 20:00','DD-MM-YYYY hh24:mi'),'Masajes',8);
INSERT INTO gastos_extras VALUES ('05','05',to_DATE('11-01-2016 16:00','DD-MM-YYYY hh24:mi'),'Spa',8);
INSERT INTO gastos_extras VALUES ('06','07',to_DATE('24-02-2016 16:45','DD-MM-YYYY hh24:mi'),'Alquiler de bicicletas',5);
INSERT INTO gastos_extras VALUES ('07','02',to_DATE('20-09-2015 16:00','DD-MM-YYYY hh24:mi'),'Television',2);
INSERT INTO gastos_extras VALUES ('08','04',to_DATE('02-08-2015 13:30','DD-MM-YYYY hh24:mi'),'Rellenar minibar', 15);
INSERT INTO gastos_extras VALUES ('09','00',to_DATE('12-03-2016 18:15','DD-MM-YYYY hh24:mi'),'Aire acondicionado', 6);
INSERT INTO gastos_extras VALUES ('10','06',to_DATE('28-12-2015 19:23','DD-MM-YYYY hh24:mi'),'Telefono',3);
INSERT INTO gastos_extras VALUES ('11','02',to_DATE('21-09-2015 10:00','DD-MM-YYYY hh24:mi'),'Alquiler de pistas',2);

---Actividades -- codigo, nombre, descripcion, precioporpersona, comisionhotel, costepersonaparahotel
INSERT INTO actividades VALUES ('A001','Aventura','Red de cuevas naturales visitables-Barrancos',15,3.74,0);
INSERT INTO actividades VALUES ('C093','Curso','Espeleologia- iniciacion',75,13,10);
INSERT INTO actividades VALUES ('B302','Hipica','Montar a caballo durante 2 hORas',22,4,5);
INSERT INTO actividades VALUES ('A032','Tiro con Arco','4?u desperfecto de flecha',12,2,4);

---Actividades Realizadas -- codigoestancia, codigoactividad, fecha, numpersonas, abonado
INSERT INTO actividadesrealizadas VALUES ('01','A001',to_DATE('20-05-2015 17:30','DD-MM-YYYY hh24:mi'),2,'S');
INSERT INTO actividadesrealizadas VALUES ('07','C093',to_DATE('25-02-2016 18:00','DD-MM-YYYY hh24:mi'),5,'N');
INSERT INTO actividadesrealizadas VALUES ('06','B302',to_DATE('29-12-2015 12:00','DD-MM-YYYY hh24:mi'),1,'N');
INSERT INTO actividadesrealizadas VALUES ('04','A032',to_DATE('04-08-2015 11:30','DD-MM-YYYY hh24:mi'),2,'S');
INSERT INTO actividadesrealizadas VALUES ('01','C093',to_DATE('21-05-2015 17:00','DD-MM-YYYY hh24:mi'),2,'N');
INSERT INTO actividadesrealizadas VALUES ('05','A001',to_DATE('10-01-2016 16:15','DD-MM-YYYY hh24:mi'),4,'S');
INSERT INTO actividadesrealizadas VALUES ('07','B302',to_DATE('28-02-2016 17:45','DD-MM-YYYY hh24:mi'),3,'N');
INSERT INTO actividadesrealizadas VALUES ('04','A032',to_DATE('07-08-2015 12:15','DD-MM-YYYY hh24:mi'),6,'S');