-- ====================== TABLA BASE ======================
CREATE TABLE PERSONA (
id_persona NUMBER PRIMARY KEY,
nombre_per VARCHAR2(100) NOT NULL,
apellido_paterno VARCHAR2(80) NOT NULL,
apellido_materno VARCHAR2(80),
fecha_nac DATE,
ci_documento VARCHAR2(20) UNIQUE NOT NULL,
telefono_per VARCHAR2(20),
correo_per VARCHAR2(120) UNIQUE,
edad NUMBER(3) CHECK (edad >= 0 AND edad <= 120)
);

-- ====================== EMPRESA ======================
CREATE TABLE EMPRESA_DELIVERY (
id_empresa NUMBER PRIMARY KEY,
razon_social VARCHAR2(150) NOT NULL,
nit_empresa VARCHAR2(25) UNIQUE NOT NULL,
telefono_central VARCHAR2(20),
tarifa_base NUMBER(10,2) NOT NULL CHECK (tarifa_base >= 0),
costo_por_km NUMBER(8,2) NOT NULL CHECK (costo_por_km >= 0),
estado_empresa VARCHAR2(20) DEFAULT 'Activo'
CHECK (estado_empresa IN ('Activo', 'Inactivo', 'Suspendido'))
);

-- ====================== CLIENTE ======================
CREATE TABLE CLIENTE (
id_persona NUMBER PRIMARY KEY,
puntos_fidelidad NUMBER DEFAULT 0 CHECK (puntos_fidelidad >= 0),
fecha_registro DATE DEFAULT SYSDATE,
estado_cliente VARCHAR2(20) DEFAULT 'Activo'
CHECK (estado_cliente IN ('Activo', 'Inactivo', 'Suspendido')),
CONSTRAINT fk_cliente_persona FOREIGN KEY (id_persona)
REFERENCES PERSONA(id_persona) ON DELETE CASCADE
);

-- ====================== REPARTIDOR ======================
CREATE TABLE REPARTIDOR (
id_persona NUMBER PRIMARY KEY,
nro_licencia VARCHAR2(30) UNIQUE,
estado_disponibilidad VARCHAR2(20) DEFAULT 'Disponible'
CHECK (estado_disponibilidad IN ('Disponible', 'Ocupado', 'Fuera de servicio')),
medio_transporte VARCHAR2(30),
salario NUMBER(10,2) CHECK (salario >= 0),
id_empresa NUMBER NOT NULL,
CONSTRAINT fk_repartidor_persona FOREIGN KEY (id_persona)
REFERENCES PERSONA(id_persona) ON DELETE CASCADE,
CONSTRAINT fk_repartidor_empresa FOREIGN KEY (id_empresa)
REFERENCES EMPRESA_DELIVERY(id_empresa)
);

-- ====================== NEGOCIO ======================
CREATE TABLE NEGOCIO (
id_negocio NUMBER PRIMARY KEY,
nombre_negocio VARCHAR2(150) NOT NULL,
tipo_negocio VARCHAR2(50),
hora_apertura VARCHAR2(5),
hora_cierre VARCHAR2(5),
dias_atencion VARCHAR2(100),
estado_negocio VARCHAR2(20) DEFAULT 'Activo'
CHECK (estado_negocio IN ('Activo', 'Inactivo', 'Cerrado'))
);

-- ====================== SUCURSAL ======================
CREATE TABLE SUCURSAL (
id_sucursal NUMBER PRIMARY KEY,
nombre_sucursal VARCHAR2(100) NOT NULL,
zona_suc VARCHAR2(80) NOT NULL,
calle_suc VARCHAR2(120) NOT NULL,
id_negocio NUMBER NOT NULL,
CONSTRAINT fk_sucursal_negocio FOREIGN KEY (id_negocio)
REFERENCES NEGOCIO(id_negocio) ON DELETE CASCADE
);

-- ====================== PRODUCTO ======================
CREATE TABLE PRODUCTO (
id_producto NUMBER PRIMARY KEY,
nombre_producto VARCHAR2(150) NOT NULL,
descripcion_producto VARCHAR2(4000),
precio_unitario NUMBER(10,2) NOT NULL CHECK (precio_unitario > 0),
estado_producto VARCHAR2(20) DEFAULT 'Activo'
CHECK (estado_producto IN ('Activo', 'Inactivo', 'Agotado'))
);

-- ====================== DIRECCION ======================
CREATE TABLE DIRECCION (
id_direccion NUMBER PRIMARY KEY,
zona_cli VARCHAR2(80) NOT NULL,
calle_cli VARCHAR2(120) NOT NULL,
numero_puerta VARCHAR2(20),
id_cliente NUMBER NOT NULL,
CONSTRAINT fk_direccion_cliente FOREIGN KEY (id_cliente)
REFERENCES CLIENTE(id_persona) ON DELETE CASCADE
);

-- ====================== PEDIDO ======================
CREATE TABLE PEDIDO (
id_pedido NUMBER PRIMARY KEY,
fecha_solicitud DATE DEFAULT SYSDATE,
hora_solicitud VARCHAR2(5),
estado_pedido VARCHAR2(30) DEFAULT 'Pendiente'
CHECK (estado_pedido IN ('Pendiente', 'Confirmado', 'En preparación',
'Listo para entregar', 'En camino',
'Entregado', 'Cancelado')),
total_productos NUMBER(12,2) DEFAULT 0 CHECK (total_productos >= 0),
costo_envio NUMBER(10,2) DEFAULT 0 CHECK (costo_envio >= 0),
total_final NUMBER(12,2) DEFAULT 0 CHECK (total_final >= 0),
id_cliente NUMBER NOT NULL,
id_direccion NUMBER NOT NULL,
id_repartidor NUMBER,
CONSTRAINT fk_pedido_cliente FOREIGN KEY (id_cliente) REFERENCES CLIENTE(id_persona),
CONSTRAINT fk_pedido_direccion FOREIGN KEY (id_direccion) REFERENCES DIRECCION(id_direccion),
CONSTRAINT fk_pedido_repartidor FOREIGN KEY (id_repartidor) REFERENCES REPARTIDOR(id_persona)
);

-- ====================== PAGO ======================
CREATE TABLE PAGO (
id_pago NUMBER PRIMARY KEY,
tipo_pago VARCHAR2(30) NOT NULL
CHECK (tipo_pago IN ('Efectivo', 'Tarjeta', 'QR', 'Transferencia', 'App')),
monto NUMBER(12,2) NOT NULL CHECK (monto > 0),
estado_pago VARCHAR2(20) DEFAULT 'Pendiente'
CHECK (estado_pago IN ('Pendiente', 'Pagado', 'Rechazado', 'Reembolsado')),
fecha_pago DATE DEFAULT SYSDATE,
id_pedido NUMBER NOT NULL,
CONSTRAINT fk_pago_pedido FOREIGN KEY (id_pedido)
REFERENCES PEDIDO(id_pedido) ON DELETE CASCADE
);

-- ====================== FACTURA ======================
CREATE TABLE FACTURA (
id_factura NUMBER PRIMARY KEY,
numero_factura VARCHAR2(30) UNIQUE NOT NULL,
fecha_emision DATE DEFAULT SYSDATE,
fecha_vencimiento DATE,
subtotal NUMBER(12,2) NOT NULL CHECK (subtotal >= 0),
total_factura NUMBER(12,2) NOT NULL CHECK (total_factura >= 0),
estado_factura VARCHAR2(20) DEFAULT 'Emitida'
CHECK (estado_factura IN ('Emitida', 'Pagada', 'Anulada', 'Vencida')),
id_pedido NUMBER NOT NULL UNIQUE,
CONSTRAINT fk_factura_pedido FOREIGN KEY (id_pedido)
REFERENCES PEDIDO(id_pedido) ON DELETE CASCADE
);

-- ====================== PROMOCION ======================
CREATE TABLE PROMOCION (
id_promocion NUMBER PRIMARY KEY,
descripcion_promocion VARCHAR2(200) NOT NULL,
tipo_promocion VARCHAR2(50),
porcentaje_descuento NUMBER(5,2) CHECK (porcentaje_descuento BETWEEN 0 AND 100),
estado_promo VARCHAR2(20) DEFAULT 'Activa'
CHECK (estado_promo IN ('Activa', 'Inactiva', 'Vencida')),
fecha_inicio DATE NOT NULL,
fecha_fin DATE NOT NULL,
id_sucursal NUMBER NOT NULL,
CONSTRAINT fk_promocion_sucursal FOREIGN KEY (id_sucursal)
REFERENCES SUCURSAL(id_sucursal) ON DELETE CASCADE,
CHECK (fecha_fin >= fecha_inicio)
);

-- ====================== TABLAS INTERMEDIAS ======================
CREATE TABLE OFRECE (
id_sucursal NUMBER NOT NULL,
id_producto NUMBER NOT NULL,
CONSTRAINT pk_ofrece PRIMARY KEY (id_sucursal, id_producto),
CONSTRAINT fk_ofrece_sucursal FOREIGN KEY (id_sucursal) REFERENCES SUCURSAL(id_sucursal) ON DELETE CASCADE,
CONSTRAINT fk_ofrece_producto FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto) ON DELETE CASCADE
);

CREATE TABLE CONTIENE (
id_pedido NUMBER NOT NULL,
id_producto NUMBER NOT NULL,
id_sucursal NUMBER NOT NULL,
cantidad NUMBER(5) NOT NULL CHECK (cantidad > 0),
CONSTRAINT pk_contiene PRIMARY KEY (id_pedido, id_producto, id_sucursal),
CONSTRAINT fk_contiene_pedido FOREIGN KEY (id_pedido) REFERENCES PEDIDO(id_pedido) ON DELETE CASCADE,
CONSTRAINT fk_contiene_producto FOREIGN KEY (id_producto) REFERENCES PRODUCTO(id_producto),
CONSTRAINT fk_contiene_sucursal FOREIGN KEY (id_sucursal) REFERENCES SUCURSAL(id_sucursal)
);

CREATE TABLE RECIBE (
id_pedido NUMBER NOT NULL,
id_sucursal NUMBER NOT NULL,
CONSTRAINT pk_recibe PRIMARY KEY (id_pedido, id_sucursal),
CONSTRAINT fk_recibe_pedido FOREIGN KEY (id_pedido) REFERENCES PEDIDO(id_pedido) ON DELETE CASCADE,
CONSTRAINT fk_recibe_sucursal FOREIGN KEY (id_sucursal) REFERENCES SUCURSAL(id_sucursal)
);

CREATE TABLE SE_ASOCIA (
id_empresa NUMBER NOT NULL,
id_negocio NUMBER NOT NULL,
CONSTRAINT pk_se_asocia PRIMARY KEY (id_empresa, id_negocio),
CONSTRAINT fk_asocia_empresa FOREIGN KEY (id_empresa) REFERENCES EMPRESA_DELIVERY(id_empresa) ON DELETE CASCADE,
CONSTRAINT fk_asocia_negocio FOREIGN KEY (id_negocio) REFERENCES NEGOCIO(id_negocio) ON DELETE CASCADE
);
------------------------


--PERSONA
BEGIN
  INSERT INTO PERSONA VALUES (1001, 'Pedro', 'Mamani', 'Herrera', TO_DATE('1990-01-15', 'YYYY-MM-DD'), '8301001', '71021001', 'pedro.mamani.90@gmail.com', 36);
  INSERT INTO PERSONA VALUES (1002, 'Daniela', 'Quispe', 'Ortiz', TO_DATE('1985-06-22', 'YYYY-MM-DD'), '6401002', '60121002', 'dani.quispe85@hotmail.com', 40);
  INSERT INTO PERSONA VALUES (1003, 'Luis', 'Choque', 'Torres', TO_DATE('1997-02-19', 'YYYY-MM-DD'), '8501003', '75021003', 'luis.choque.97@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1004, 'Jorge', 'Condori', 'Ortiz', TO_DATE('1992-01-30', 'YYYY-MM-DD'), '7601004', '77021004', 'jorge.condori.1992@gmail.com', 34);
  INSERT INTO PERSONA VALUES (1005, 'Miguel', 'Vargas', NULL, TO_DATE('1989-11-13', 'YYYY-MM-DD'), '8701005', '68021005', 'miguel.vargas89@hotmail.com', 36);
  INSERT INTO PERSONA VALUES (1006, 'Diego', 'Rojas', NULL, TO_DATE('1961-01-01', 'YYYY-MM-DD'), '2301006', '71521006', 'diego.rojas61@gmail.com', 65);
  INSERT INTO PERSONA VALUES (1007, 'Miguel', 'Flores', 'Mendoza', TO_DATE('1972-09-02', 'YYYY-MM-DD'), '4501007', '65021007', 'm.flores.72@yahoo.com', 53);
  INSERT INTO PERSONA VALUES (1008, 'Daniela', 'Gutiérrez', 'Rodríguez', TO_DATE('2001-08-20', 'YYYY-MM-DD'), '12401008', '76021008', 'dani.gutierrez01@gmail.com', 24);
  INSERT INTO PERSONA VALUES (1009, 'Jorge', 'Apaza', NULL, TO_DATE('1975-08-02', 'YYYY-MM-DD'), '3401009', '77021009', 'jorge.apaza75@gmail.com', 50);
  INSERT INTO PERSONA VALUES (1010, 'Ana', 'Copana', 'Silva', TO_DATE('1985-07-26', 'YYYY-MM-DD'), '5601010', '71221010', 'ana.copana.85@hotmail.com', 40);
  INSERT INTO PERSONA VALUES (1011, 'Diego', 'Callisaya', 'Ramírez', TO_DATE('1981-07-28', 'YYYY-MM-DD'), '6701011', '68121011', 'diego.calli81@gmail.com', 44);
  INSERT INTO PERSONA VALUES (1012, 'Andrea', 'Huanca', NULL, TO_DATE('1976-04-14', 'YYYY-MM-DD'), '4801012', '71521012', 'andrea.huanca.76@gmail.com', 50);
  INSERT INTO PERSONA VALUES (1013, 'Fernando', 'Ticona', 'Pérez', TO_DATE('1998-09-12', 'YYYY-MM-DD'), '9901013', '75021013', 'fer.ticona98@hotmail.com', 27);
  INSERT INTO PERSONA VALUES (1014, 'José', 'Arias', 'Castillo', TO_DATE('1999-10-05', 'YYYY-MM-DD'), '8101014', '77021014', 'jose.arias99@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1015, 'Francisco', 'Poma', 'Herrera', TO_DATE('1977-04-07', 'YYYY-MM-DD'), '3201015', '68021015', 'fran.poma.77@gmail.com', 49);
  INSERT INTO PERSONA VALUES (1016, 'Isabel', 'Cruz', 'Ramírez', TO_DATE('1972-05-04', 'YYYY-MM-DD'), '4301016', '71021016', 'isa.cruz.1972@yahoo.com', 54);
  INSERT INTO PERSONA VALUES (1017, 'Andrea', 'Machaca', 'Rojas', TO_DATE('1967-11-30', 'YYYY-MM-DD'), '2401017', '65021017', 'andrea.machaca67@gmail.com', 58);
  INSERT INTO PERSONA VALUES (1018, 'José', 'Yujra', NULL, TO_DATE('1964-05-14', 'YYYY-MM-DD'), '1501018', '76021018', 'jose.yujra.64@hotmail.com', 62);
  INSERT INTO PERSONA VALUES (1019, 'Francisco', 'Lima', 'Sánchez', TO_DATE('1973-01-08', 'YYYY-MM-DD'), '2601019', '77021019', 'f.lima.73@gmail.com', 53);
  INSERT INTO PERSONA VALUES (1020, 'Carmen', 'Nina', 'Ortiz', TO_DATE('2003-05-26', 'YYYY-MM-DD'), '12701020', '71221020', 'carmen.nina.03@gmail.com', 22);
  INSERT INTO PERSONA VALUES (1021, 'Elena', 'Colque', 'Castillo', TO_DATE('1985-09-15', 'YYYY-MM-DD'), '6801021', '68121021', 'elena.colque85@hotmail.com', 40);
  INSERT INTO PERSONA VALUES (1022, 'Fernando', 'Tarqui', 'González', TO_DATE('1967-08-26', 'YYYY-MM-DD'), '3901022', '71521022', 'fer.tarqui67@gmail.com', 58);
  INSERT INTO PERSONA VALUES (1023, 'Antonio', 'Aliaga', NULL, TO_DATE('1980-10-06', 'YYYY-MM-DD'), '4001023', '75021023', 'antonio.aliaga80@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1024, 'Paula', 'Mendoza', 'Rojas', TO_DATE('2001-09-14', 'YYYY-MM-DD'), '13101024', '77021024', 'paula.mendoza01@gmail.com', 24);
  INSERT INTO PERSONA VALUES (1025, 'Daniela', 'Patzi', 'Herrera', TO_DATE('1983-03-15', 'YYYY-MM-DD'), '5201025', '68021025', 'dani.patzi.83@yahoo.com', 43);
  INSERT INTO PERSONA VALUES (1026, 'Antonio', 'Molina', 'Ramírez', TO_DATE('1998-10-04', 'YYYY-MM-DD'), '9301026', '71021026', 'antonio.molina98@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1027, 'Miguel', 'Aruquipa', 'García', TO_DATE('1979-07-16', 'YYYY-MM-DD'), '4401027', '65021027', 'miguel.aruquipa79@hotmail.com', 46);
  INSERT INTO PERSONA VALUES (1028, 'Sofía', 'Chura', 'Silva', TO_DATE('1965-05-03', 'YYYY-MM-DD'), '2501028', '76021028', 'sofia.chura.65@gmail.com', 61);
  INSERT INTO PERSONA VALUES (1029, 'Miguel', 'Villca', NULL, TO_DATE('2003-02-22', 'YYYY-MM-DD'), '13601029', '77021029', 'miguel.villca03@gmail.com', 23);
  INSERT INTO PERSONA VALUES (1030, 'Miguel', 'Guzmán', 'Martínez', TO_DATE('1991-10-07', 'YYYY-MM-DD'), '8701030', '71221030', 'miguel.guzman91@gmail.com', 34);
  INSERT INTO PERSONA VALUES (1031, 'Daniela', 'Siles', 'Martínez', TO_DATE('1989-03-15', 'YYYY-MM-DD'), '7801031', '68121031', 'dani.siles.89@hotmail.com', 37);
  INSERT INTO PERSONA VALUES (1032, 'Carmen', 'Paredes', 'Ruiz', TO_DATE('1976-03-29', 'YYYY-MM-DD'), '5901032', '71521032', 'carmen.paredes.76@gmail.com', 50);
  INSERT INTO PERSONA VALUES (1033, 'Sofía', 'Cáceres', NULL, TO_DATE('1971-03-07', 'YYYY-MM-DD'), '3001033', '75021033', 'sofia.caceres71@gmail.com', 55);
  INSERT INTO PERSONA VALUES (1034, 'Valentina', 'Orellana', 'Ortiz', TO_DATE('1974-02-06', 'YYYY-MM-DD'), '4101034', '77021034', 'vale.orellana.74@yahoo.com', 52);
  INSERT INTO PERSONA VALUES (1035, 'Antonio', 'Ríos', 'Martínez', TO_DATE('1983-08-04', 'YYYY-MM-DD'), '5201035', '68021035', 'antonio.rios83@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1036, 'Pedro', 'Aguilar', 'Herrera', TO_DATE('2004-04-15', 'YYYY-MM-DD'), '14301036', '71021036', 'pedro.aguilar.04@gmail.com', 22);
  INSERT INTO PERSONA VALUES (1037, 'Pedro', 'Salazar', 'Vargas', TO_DATE('1990-11-03', 'YYYY-MM-DD'), '8401037', '65021037', 'pedro.salazar90@hotmail.com', 35);
  INSERT INTO PERSONA VALUES (1038, 'Sofía', 'Miranda', 'Vargas', TO_DATE('1966-05-31', 'YYYY-MM-DD'), '2501038', '76021038', 'sofia.miranda66@gmail.com', 60);
  INSERT INTO PERSONA VALUES (1039, 'Fernando', 'Arce', 'Medina', TO_DATE('2006-11-24', 'YYYY-MM-DD'), '14601039', '77021039', 'fer.arce.06@gmail.com', 19);
  INSERT INTO PERSONA VALUES (1040, 'Daniela', 'Pacheco', NULL, TO_DATE('1999-01-16', 'YYYY-MM-DD'), '9701040', '71221040', 'dani.pacheco99@hotmail.com', 27);
  INSERT INTO PERSONA VALUES (1041, 'Sofía', 'Vera', 'Herrera', TO_DATE('1986-12-21', 'YYYY-MM-DD'), '6801041', '68121041', 'sofia.vera86@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1042, 'Paula', 'Encinas', 'López', TO_DATE('2002-09-13', 'YYYY-MM-DD'), '12901042', '71521042', 'paula.encinas02@gmail.com', 23);
  INSERT INTO PERSONA VALUES (1043, 'Pedro', 'Escobar', NULL, TO_DATE('1977-01-23', 'YYYY-MM-DD'), '4001043', '75021043', 'pedro.escobar.77@yahoo.com', 49);
  INSERT INTO PERSONA VALUES (1044, 'Antonio', 'Camacho', 'Medina', TO_DATE('1997-02-14', 'YYYY-MM-DD'), '8101044', '77021044', 'antonio.camacho97@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1045, 'Isabel', 'Sosa', 'Castillo', TO_DATE('1986-10-16', 'YYYY-MM-DD'), '6201045', '68021045', 'isa.sosa86@hotmail.com', 39);
  INSERT INTO PERSONA VALUES (1046, 'María', 'Lazo', 'González', TO_DATE('1982-11-15', 'YYYY-MM-DD'), '5301046', '71021046', 'maria.lazo.82@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1047, 'Rafael', 'Cano', 'Ramírez', TO_DATE('1986-03-22', 'YYYY-MM-DD'), '6401047', '65021047', 'rafa.cano86@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1048, 'Andrés', 'Tapia', 'Ruiz', TO_DATE('1971-08-03', 'YYYY-MM-DD'), '3501048', '76021048', 'andres.tapia71@hotmail.com', 54);
  INSERT INTO PERSONA VALUES (1049, 'Miguel', 'Mora', 'Morales', TO_DATE('1997-05-01', 'YYYY-MM-DD'), '8601049', '77021049', 'miguel.mora.97@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1050, 'Roberto', 'Montoya', NULL, TO_DATE('1961-10-11', 'YYYY-MM-DD'), '2701050', '71221050', 'roberto.montoya61@gmail.com', 64);
  INSERT INTO PERSONA VALUES (1051, 'José', 'Serrano', 'García', TO_DATE('1960-11-21', 'YYYY-MM-DD'), '1801051', '68121051', 'jose.serrano.60@yahoo.com', 65);
  INSERT INTO PERSONA VALUES (1052, 'Andrés', 'Coronel', 'González', TO_DATE('1975-07-21', 'YYYY-MM-DD'), '3901052', '71521052', 'andres.coronel75@gmail.com', 50);
  INSERT INTO PERSONA VALUES (1053, 'Diego', 'Crespo', NULL, TO_DATE('2007-05-12', 'YYYY-MM-DD'), '15001053', '75021053', 'diego.crespo07@hotmail.com', 18);
  INSERT INTO PERSONA VALUES (1054, 'Andrea', 'Delgado', 'Martínez', TO_DATE('2001-10-17', 'YYYY-MM-DD'), '13101054', '77021054', 'andrea.delgado.01@gmail.com', 24);
  INSERT INTO PERSONA VALUES (1055, 'Francisco', 'Pinto', 'González', TO_DATE('1983-03-21', 'YYYY-MM-DD'), '6201055', '68021055', 'fran.pinto83@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1056, 'Carmen', 'Salinas', NULL, TO_DATE('2000-08-05', 'YYYY-MM-DD'), '12301056', '71021056', 'carmen.salinas00@hotmail.com', 25);
  INSERT INTO PERSONA VALUES (1057, 'Carlos', 'Vallejos', 'López', TO_DATE('1972-06-09', 'YYYY-MM-DD'), '4401057', '65021057', 'carlos.vallejos72@gmail.com', 53);
  INSERT INTO PERSONA VALUES (1058, 'Antonio', 'Carrillo', 'Castillo', TO_DATE('1990-07-24', 'YYYY-MM-DD'), '8501058', '76021058', 'antonio.carrillo.90@gmail.com', 35);
  INSERT INTO PERSONA VALUES (1059, 'Camila', 'Velasco', 'Sánchez', TO_DATE('1999-12-20', 'YYYY-MM-DD'), '9601059', '77021059', 'camila.velasco99@yahoo.com', 26);
  INSERT INTO PERSONA VALUES (1060, 'José', 'Huarachi', 'Vargas', TO_DATE('1969-08-02', 'YYYY-MM-DD'), '2701060', '71221060', 'jose.huarachi69@gmail.com', 56);
  INSERT INTO PERSONA VALUES (1061, 'Lucía', 'Peña', NULL, TO_DATE('1964-04-01', 'YYYY-MM-DD'), '1801061', '68121061', 'lucia.pena.64@hotmail.com', 62);
  INSERT INTO PERSONA VALUES (1062, 'Carmen', 'Zarate', 'González', TO_DATE('1965-09-20', 'YYYY-MM-DD'), '1901062', '71521062', 'carmen.zarate65@gmail.com', 60);
  INSERT INTO PERSONA VALUES (1063, 'Natalia', 'Chávez', 'González', TO_DATE('1998-02-21', 'YYYY-MM-DD'), '9001063', '75021063', 'naty.chavez.98@gmail.com', 28);
  INSERT INTO PERSONA VALUES (1064, 'Carlos', 'Montero', 'Rodríguez', TO_DATE('1979-10-02', 'YYYY-MM-DD'), '4101064', '77021064', 'carlos.montero79@hotmail.com', 46);
  INSERT INTO PERSONA VALUES (1065, 'María', 'Lora', 'Rodríguez', TO_DATE('1988-06-01', 'YYYY-MM-DD'), '7201065', '68021065', 'maria.lora88@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1066, 'Elena', 'Bustamante', 'Herrera', TO_DATE('1993-10-24', 'YYYY-MM-DD'), '8301066', '71021066', 'elena.busta.93@gmail.com', 32);
  INSERT INTO PERSONA VALUES (1067, 'Sofía', 'Cárdenas', NULL, TO_DATE('2001-11-04', 'YYYY-MM-DD'), '13401067', '65021067', 'sofia.cardenas01@yahoo.com', 24);
  INSERT INTO PERSONA VALUES (1068, 'Elena', 'Maclean', NULL, TO_DATE('1975-01-27', 'YYYY-MM-DD'), '3501068', '76021068', 'elena.maclean75@gmail.com', 51);
  INSERT INTO PERSONA VALUES (1069, 'Ana', 'Roca', 'Morales', TO_DATE('1980-03-02', 'YYYY-MM-DD'), '4601069', '77021069', 'ana.roca.80@hotmail.com', 46);
  INSERT INTO PERSONA VALUES (1070, 'Carlos', 'Villarroel', 'Rojas', TO_DATE('1980-05-29', 'YYYY-MM-DD'), '4701070', '71221070', 'carlos.villarroel80@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1071, 'Gabriela', 'Aguilera', 'Ramírez', TO_DATE('2001-11-20', 'YYYY-MM-DD'), '12801071', '68121071', 'gaby.aguilera01@gmail.com', 24);
  INSERT INTO PERSONA VALUES (1072, 'Jorge', 'Soria', 'Herrera', TO_DATE('1963-12-10', 'YYYY-MM-DD'), '1901072', '71521072', 'jorge.soria.63@hotmail.com', 62);
  INSERT INTO PERSONA VALUES (1073, 'Lucía', 'Balderrama', NULL, TO_DATE('1999-07-25', 'YYYY-MM-DD'), '9001073', '75021073', 'lucia.balde99@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1074, 'Elena', 'Guevara', 'Medina', TO_DATE('2006-10-16', 'YYYY-MM-DD'), '14101074', '77021074', 'elena.guevara06@gmail.com', 19);
  INSERT INTO PERSONA VALUES (1075, 'Camila', 'Alba', 'Mendoza', TO_DATE('1978-06-04', 'YYYY-MM-DD'), '4201075', '68021075', 'camila.alba.78@yahoo.com', 47);
  INSERT INTO PERSONA VALUES (1076, 'Ana', 'Cordero', NULL, TO_DATE('1998-11-06', 'YYYY-MM-DD'), '9301076', '71021076', 'ana.cordero98@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1077, 'Juan', 'Becerra', 'Morales', TO_DATE('1999-09-28', 'YYYY-MM-DD'), '9401077', '65021077', 'juan.becerra.99@hotmail.com', 26);
  INSERT INTO PERSONA VALUES (1078, 'Pedro', 'Salinas', NULL, TO_DATE('1962-01-07', 'YYYY-MM-DD'), '1501078', '76021078', 'pedro.salinas62@gmail.com', 64);
  INSERT INTO PERSONA VALUES (1079, 'Laura', 'Díaz', 'Mendoza', TO_DATE('1992-10-23', 'YYYY-MM-DD'), '8601079', '77021079', 'laura.diaz.92@gmail.com', 33);
  INSERT INTO PERSONA VALUES (1080, 'Ana', 'Romero', 'Ruiz', TO_DATE('1980-01-08', 'YYYY-MM-DD'), '4701080', '71221080', 'ana.romero80@hotmail.com', 46);
  INSERT INTO PERSONA VALUES (1081, 'Antonio', 'Blanco', 'Morales', TO_DATE('2003-11-19', 'YYYY-MM-DD'), '13801081', '68121081', 'antonio.blanco03@gmail.com', 22);
  INSERT INTO PERSONA VALUES (1082, 'Diego', 'Rivas', 'Martínez', TO_DATE('1976-05-15', 'YYYY-MM-DD'), '3901082', '71521082', 'diego.rivas.76@yahoo.com', 49);
  INSERT INTO PERSONA VALUES (1083, 'Francisco', 'Paredes', 'López', TO_DATE('1988-04-01', 'YYYY-MM-DD'), '7001083', '75021083', 'fran.paredes88@gmail.com', 38);
  INSERT INTO PERSONA VALUES (1084, 'Lucía', 'Navarro', 'López', TO_DATE('1975-03-20', 'YYYY-MM-DD'), '3101084', '77021084', 'lucia.navarro.75@gmail.com', 51);
  INSERT INTO PERSONA VALUES (1085, 'Valentina', 'Soto', 'Ramírez', TO_DATE('1999-03-30', 'YYYY-MM-DD'), '9201085', '68021085', 'vale.soto99@hotmail.com', 27);
  INSERT INTO PERSONA VALUES (1086, 'Roberto', 'Molina', 'Ortiz', TO_DATE('1964-11-12', 'YYYY-MM-DD'), '1301086', '71021086', 'roberto.molina64@gmail.com', 61);
  INSERT INTO PERSONA VALUES (1087, 'Ana', 'Campos', 'Morales', TO_DATE('1966-02-04', 'YYYY-MM-DD'), '2401087', '65021087', 'ana.campos.66@gmail.com', 60);
  INSERT INTO PERSONA VALUES (1088, 'Carlos', 'Vega', 'Rodríguez', TO_DATE('1990-02-28', 'YYYY-MM-DD'), '8501088', '76021088', 'carlos.vega90@yahoo.com', 36);
  INSERT INTO PERSONA VALUES (1089, 'Carmen', 'Guzmán', 'Rodríguez', TO_DATE('2000-11-02', 'YYYY-MM-DD'), '12601089', '77021089', 'carmen.guzman00@gmail.com', 25);
  INSERT INTO PERSONA VALUES (1090, 'Roberto', 'Peña', 'Ramírez', TO_DATE('1999-05-18', 'YYYY-MM-DD'), '9701090', '71221090', 'roberto.pena.99@hotmail.com', 26);
  INSERT INTO PERSONA VALUES (1091, 'Paula', 'Mora', NULL, TO_DATE('1988-08-17', 'YYYY-MM-DD'), '7801091', '68121091', 'paula.mora88@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1092, 'José', 'Rey', 'Rojas', TO_DATE('1988-06-05', 'YYYY-MM-DD'), '7901092', '71521092', 'jose.rey.88@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1093, 'Roberto', 'Cruz', 'Pérez', TO_DATE('1972-05-16', 'YYYY-MM-DD'), '4001093', '75021093', 'roberto.cruz72@hotmail.com', 53);
  INSERT INTO PERSONA VALUES (1094, 'Diego', 'Luna', 'Morales', TO_DATE('2003-06-10', 'YYYY-MM-DD'), '13101094', '77021094', 'diego.luna.03@gmail.com', 22);
  INSERT INTO PERSONA VALUES (1095, 'María', 'Cabrera', NULL, TO_DATE('1977-08-09', 'YYYY-MM-DD'), '4201095', '68021095', 'maria.cabrera77@yahoo.com', 48);
  INSERT INTO PERSONA VALUES (1096, 'Juan', 'Márquez', NULL, TO_DATE('1986-04-05', 'YYYY-MM-DD'), '6301096', '71021096', 'juan.marquez.86@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1097, 'Gabriela', 'Pino', NULL, TO_DATE('1983-03-18', 'YYYY-MM-DD'), '5401097', '65021097', 'gaby.pino83@hotmail.com', 43);
  INSERT INTO PERSONA VALUES (1098, 'Andrea', 'Salazar', NULL, TO_DATE('1985-09-08', 'YYYY-MM-DD'), '6501098', '76021098', 'andrea.salazar.85@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1099, 'Lucía', 'Vera', 'Morales', TO_DATE('2005-10-25', 'YYYY-MM-DD'), '14601099', '77021099', 'lucia.vera05@gmail.com', 20);
  INSERT INTO PERSONA VALUES (1100, 'Diego', 'Gallo', 'Ramírez', TO_DATE('1972-08-18', 'YYYY-MM-DD'), '4701100', '71221100', 'diego.gallo.72@hotmail.com', 53);
  COMMIT;
END;



BEGIN
  INSERT INTO PERSONA VALUES (1101, 'Mateo', 'Mamani', 'Tapia', TO_DATE('1994-03-12', 'YYYY-MM-DD'), '8301101', '71021101', 'mateo.mamani.94@gmail.com', 32);
  INSERT INTO PERSONA VALUES (1102, 'Valeria', 'Quispe', 'Molina', TO_DATE('1988-11-05', 'YYYY-MM-DD'), '7401102', '60121102', 'vale.quispe88@hotmail.com', 37);
  INSERT INTO PERSONA VALUES (1103, 'Sebastián', 'Choque', 'Castro', TO_DATE('2000-07-19', 'YYYY-MM-DD'), '12501103', '75021103', 'sebas.choque.00@gmail.com', 25);
  INSERT INTO PERSONA VALUES (1104, 'Isabella', 'Condori', 'Vega', TO_DATE('1995-09-28', 'YYYY-MM-DD'), '8601104', '77021104', 'isa.condori95@gmail.com', 30);
  INSERT INTO PERSONA VALUES (1105, 'Joaquín', 'Vargas', 'Delgado', TO_DATE('1982-12-14', 'YYYY-MM-DD'), '5701105', '68021105', 'joaquin.vargas.82@hotmail.com', 43);
  INSERT INTO PERSONA VALUES (1106, 'Martina', 'Rojas', 'Guzmán', TO_DATE('1991-04-22', 'YYYY-MM-DD'), '8801106', '71521106', 'martina.rojas91@gmail.com', 34);
  INSERT INTO PERSONA VALUES (1107, 'Emilio', 'Flores', 'Ramos', TO_DATE('1979-08-08', 'YYYY-MM-DD'), '4901107', '65021107', 'emilio.flores.79@yahoo.com', 46);
  INSERT INTO PERSONA VALUES (1108, 'Julieta', 'Gutiérrez', 'Iglesias', TO_DATE('2002-01-15', 'YYYY-MM-DD'), '13001108', '76021108', 'julieta.gutierrez02@gmail.com', 24);
  INSERT INTO PERSONA VALUES (1109, 'Santiago', 'Apaza', 'Soto', TO_DATE('1996-05-30', 'YYYY-MM-DD'), '9101109', '77021109', 'santiago.apaza.96@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1110, 'Renata', 'Copana', 'Lara', TO_DATE('1987-10-11', 'YYYY-MM-DD'), '6201110', '71221110', 'renata.copana87@hotmail.com', 38);
  INSERT INTO PERSONA VALUES (1111, 'Matías', 'Callisaya', 'Márquez', TO_DATE('1993-02-25', 'YYYY-MM-DD'), '8301111', '68121111', 'matias.calli.93@gmail.com', 33);
  INSERT INTO PERSONA VALUES (1112, 'Emma', 'Huanca', 'Luna', TO_DATE('1984-06-03', 'YYYY-MM-DD'), '5401112', '71521112', 'emma.huanca84@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1113, 'Benjamín', 'Ticona', 'Paz', TO_DATE('1998-12-07', 'YYYY-MM-DD'), '9501113', '75021113', 'benjamin.ticona.98@hotmail.com', 27);
  INSERT INTO PERSONA VALUES (1114, 'Mía', 'Arias', 'León', TO_DATE('2001-03-18', 'YYYY-MM-DD'), '12601114', '77021114', 'mia.arias01@gmail.com', 25);
  INSERT INTO PERSONA VALUES (1115, 'Nicolás', 'Poma', 'Arias', TO_DATE('1976-11-29', 'YYYY-MM-DD'), '3701115', '68021115', 'nico.poma.76@gmail.com', 49);
  INSERT INTO PERSONA VALUES (1116, 'Catalina', 'Cruz', 'Brito', TO_DATE('1990-07-05', 'YYYY-MM-DD'), '8801116', '71021116', 'cata.cruz90@yahoo.com', 35);
  INSERT INTO PERSONA VALUES (1117, 'Lucas', 'Machaca', 'Nieto', TO_DATE('1985-09-14', 'YYYY-MM-DD'), '6901117', '65021117', 'lucas.machaca.85@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1118, 'Victoria', 'Yujra', 'Cano', TO_DATE('1997-01-21', 'YYYY-MM-DD'), '9001118', '76021118', 'vic.yujra97@hotmail.com', 29);
  INSERT INTO PERSONA VALUES (1119, 'Bautista', 'Lima', 'Mora', TO_DATE('1982-05-10', 'YYYY-MM-DD'), '5101119', '77021119', 'bautista.lima.82@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1120, 'Antonia', 'Nina', 'Salazar', TO_DATE('2003-08-27', 'YYYY-MM-DD'), '13201120', '71221120', 'anto.nina03@gmail.com', 22);
  INSERT INTO PERSONA VALUES (1121, 'Simón', 'Colque', 'Vidal', TO_DATE('1994-11-12', 'YYYY-MM-DD'), '8301121', '68121121', 'simon.colque.94@hotmail.com', 31);
  INSERT INTO PERSONA VALUES (1122, 'Zoe', 'Tarqui', 'Escobar', TO_DATE('1989-02-08', 'YYYY-MM-DD'), '7401122', '71521122', 'zoe.tarqui89@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1123, 'Felipe', 'Aliaga', 'Acosta', TO_DATE('1999-06-16', 'YYYY-MM-DD'), '9501123', '75021123', 'felipe.aliaga.99@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1124, 'Luna', 'Mendoza', 'Reyes', TO_DATE('1981-10-25', 'YYYY-MM-DD'), '5601124', '77021124', 'luna.mendoza81@gmail.com', 44);
  INSERT INTO PERSONA VALUES (1125, 'Martín', 'Patzi', 'Suárez', TO_DATE('1995-12-04', 'YYYY-MM-DD'), '8701125', '68021125', 'martin.patzi.95@yahoo.com', 30);
  INSERT INTO PERSONA VALUES (1126, 'Alma', 'Molina', 'Cortes', TO_DATE('2000-04-11', 'YYYY-MM-DD'), '12801126', '71021126', 'alma.molina00@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1127, 'Ignacio', 'Aruquipa', 'Rios', TO_DATE('1978-08-19', 'YYYY-MM-DD'), '4901127', '65021127', 'ignacio.aruquipa.78@hotmail.com', 47);
  INSERT INTO PERSONA VALUES (1128, 'Delfina', 'Chura', 'Gil', TO_DATE('1992-03-29', 'YYYY-MM-DD'), '8001128', '76021128', 'delfi.chura92@gmail.com', 34);
  INSERT INTO PERSONA VALUES (1129, 'Bruno', 'Villca', 'Navarro', TO_DATE('1986-07-07', 'YYYY-MM-DD'), '6101129', '77021129', 'bruno.villca.86@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1130, 'Emilia', 'Guzmán', 'Cruz', TO_DATE('1997-11-15', 'YYYY-MM-DD'), '9201130', '71221130', 'emilia.guzman97@gmail.com', 28);
  INSERT INTO PERSONA VALUES (1131, 'Jerónimo', 'Siles', 'Paz', TO_DATE('1983-01-24', 'YYYY-MM-DD'), '5301131', '68121131', 'jeronimo.siles.83@hotmail.com', 43);
  INSERT INTO PERSONA VALUES (1132, 'Juana', 'Paredes', 'Sosa', TO_DATE('2002-05-06', 'YYYY-MM-DD'), '13401132', '71521132', 'juana.paredes02@gmail.com', 24);
  INSERT INTO PERSONA VALUES (1133, 'Thiago', 'Cáceres', 'Gallo', TO_DATE('1990-10-18', 'YYYY-MM-DD'), '8501133', '75021133', 'thiago.caceres.90@gmail.com', 35);
  INSERT INTO PERSONA VALUES (1134, 'Olivia', 'Orellana', 'Ramos', TO_DATE('1987-02-27', 'YYYY-MM-DD'), '6601134', '77021134', 'olivia.orellana87@yahoo.com', 39);
  INSERT INTO PERSONA VALUES (1135, 'Lorenzo', 'Ríos', 'Mendoza', TO_DATE('1998-06-05', 'YYYY-MM-DD'), '9701135', '68021135', 'lorenzo.rios.98@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1136, 'Clara', 'Aguilar', 'Ponce', TO_DATE('1980-09-14', 'YYYY-MM-DD'), '4801136', '71021136', 'clara.aguilar80@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1137, 'Máximo', 'Salazar', 'Salinas', TO_DATE('1993-01-22', 'YYYY-MM-DD'), '8901137', '65021137', 'maximo.salazar.93@hotmail.com', 33);
  INSERT INTO PERSONA VALUES (1138, 'Mila', 'Miranda', 'Mora', TO_DATE('2001-08-01', 'YYYY-MM-DD'), '13001138', '76021138', 'mila.miranda01@gmail.com', 24);
  INSERT INTO PERSONA VALUES (1139, 'Dante', 'Arce', 'Vega', TO_DATE('1985-12-09', 'YYYY-MM-DD'), '6101139', '77021139', 'dante.arce.85@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1140, 'Sara', 'Pacheco', 'Romero', TO_DATE('1996-04-19', 'YYYY-MM-DD'), '9201140', '71221140', 'sara.pacheco96@hotmail.com', 30);
  INSERT INTO PERSONA VALUES (1141, 'Tomás', 'Vera', 'Paredes', TO_DATE('1979-11-28', 'YYYY-MM-DD'), '4301141', '68121141', 'tomas.vera.79@gmail.com', 46);
  INSERT INTO PERSONA VALUES (1142, 'Rocío', 'Encinas', 'Peña', TO_DATE('1991-03-09', 'YYYY-MM-DD'), '8401142', '71521142', 'rocio.encinas91@gmail.com', 35);
  INSERT INTO PERSONA VALUES (1143, 'Pedro', 'Escobar', 'Arias', TO_DATE('2000-07-17', 'YYYY-MM-DD'), '12501143', '75021143', 'pedro.escobar.00@yahoo.com', 25);
  INSERT INTO PERSONA VALUES (1144, 'Elena', 'Camacho', 'Montoya', TO_DATE('1984-10-26', 'YYYY-MM-DD'), '5601144', '77021144', 'elena.camacho84@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1145, 'Gaspar', 'Sosa', 'Fuentes', TO_DATE('1997-02-03', 'YYYY-MM-DD'), '9701145', '68021145', 'gaspar.sosa.97@hotmail.com', 29);
  INSERT INTO PERSONA VALUES (1146, 'Alicia', 'Lazo', 'Cortes', TO_DATE('1982-06-13', 'YYYY-MM-DD'), '5801146', '71021146', 'alicia.lazo82@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1147, 'Fausto', 'Cano', 'Rosales', TO_DATE('1994-11-21', 'YYYY-MM-DD'), '8901147', '65021147', 'fausto.cano.94@gmail.com', 31);
  INSERT INTO PERSONA VALUES (1148, 'Lola', 'Tapia', 'Castañeda', TO_DATE('2003-03-02', 'YYYY-MM-DD'), '13001148', '76021148', 'lola.tapia03@hotmail.com', 23);
  INSERT INTO PERSONA VALUES (1149, 'Gael', 'Mora', 'Bravo', TO_DATE('1989-07-10', 'YYYY-MM-DD'), '7101149', '77021149', 'gael.mora.89@gmail.com', 36);
  INSERT INTO PERSONA VALUES (1150, 'Malena', 'Montoya', 'Mejía', TO_DATE('1999-12-19', 'YYYY-MM-DD'), '9201150', '71221150', 'malena.montoya99@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1151, 'Valentín', 'Serrano', 'Valdés', TO_DATE('1981-04-28', 'YYYY-MM-DD'), '5301151', '68121151', 'valentin.serrano.81@yahoo.com', 44);
  INSERT INTO PERSONA VALUES (1152, 'Amparo', 'Coronel', 'Serrano', TO_DATE('1995-09-06', 'YYYY-MM-DD'), '8401152', '71521152', 'amparo.coronel95@gmail.com', 30);
  INSERT INTO PERSONA VALUES (1153, 'Santino', 'Crespo', 'Camacho', TO_DATE('2002-01-14', 'YYYY-MM-DD'), '13501153', '75021153', 'santino.crespo.02@hotmail.com', 24);
  INSERT INTO PERSONA VALUES (1154, 'Inés', 'Delgado', 'Pacheco', TO_DATE('1987-05-25', 'YYYY-MM-DD'), '6601154', '77021154', 'ines.delgado87@gmail.com', 38);
  INSERT INTO PERSONA VALUES (1155, 'Vicente', 'Pinto', 'Lara', TO_DATE('1993-10-02', 'YYYY-MM-DD'), '8701155', '68021155', 'vicente.pinto.93@gmail.com', 32);
  INSERT INTO PERSONA VALUES (1156, 'Renata', 'Salinas', 'Navarro', TO_DATE('1980-02-10', 'YYYY-MM-DD'), '4801156', '71021156', 'renata.salinas80@hotmail.com', 46);
  INSERT INTO PERSONA VALUES (1157, 'Ezequiel', 'Vallejos', 'Cabrera', TO_DATE('1998-06-20', 'YYYY-MM-DD'), '9901157', '65021157', 'ezequiel.vallejos.98@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1158, 'Mora', 'Carrillo', 'Aguilar', TO_DATE('1985-11-28', 'YYYY-MM-DD'), '6001158', '76021158', 'mora.carrillo85@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1159, 'Teo', 'Velasco', 'Gallo', TO_DATE('2001-04-08', 'YYYY-MM-DD'), '13101159', '77021159', 'teo.velasco.01@yahoo.com', 25);
  INSERT INTO PERSONA VALUES (1160, 'Paz', 'Huarachi', 'Brito', TO_DATE('1991-08-16', 'YYYY-MM-DD'), '8201160', '71221160', 'paz.huarachi91@gmail.com', 34);
  INSERT INTO PERSONA VALUES (1161, 'Rocco', 'Peña', 'Vidal', TO_DATE('1979-12-25', 'YYYY-MM-DD'), '4301161', '68121161', 'rocco.pena.79@hotmail.com', 46);
  INSERT INTO PERSONA VALUES (1162, 'Josefina', 'Zarate', 'Escobar', TO_DATE('1996-05-04', 'YYYY-MM-DD'), '9401162', '71521162', 'josefina.zarate96@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1163, 'Ian', 'Chávez', 'Acosta', TO_DATE('1983-09-12', 'YYYY-MM-DD'), '5501163', '75021163', 'ian.chavez.83@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1164, 'Nina', 'Montero', 'Reyes', TO_DATE('2000-02-21', 'YYYY-MM-DD'), '12601164', '77021164', 'nina.montero00@hotmail.com', 26);
  INSERT INTO PERSONA VALUES (1165, 'Cruz', 'Lora', 'Suárez', TO_DATE('1988-06-30', 'YYYY-MM-DD'), '7701165', '68021165', 'cruz.lora.88@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1166, 'Margarita', 'Bustamante', 'Gil', TO_DATE('1994-11-08', 'YYYY-MM-DD'), '8801166', '71021166', 'marga.busta94@gmail.com', 31);
  INSERT INTO PERSONA VALUES (1167, 'Lisandro', 'Cárdenas', 'Rios', TO_DATE('1981-03-18', 'YYYY-MM-DD'), '5901167', '65021167', 'lisandro.cardenas.81@yahoo.com', 45);
  INSERT INTO PERSONA VALUES (1168, 'Jazmín', 'Maclean', 'Cano', TO_DATE('2003-08-26', 'YYYY-MM-DD'), '13001168', '76021168', 'jazmin.maclean03@gmail.com', 22);
  INSERT INTO PERSONA VALUES (1169, 'Ciro', 'Roca', 'Nieto', TO_DATE('1990-01-03', 'YYYY-MM-DD'), '8101169', '77021169', 'ciro.roca.90@hotmail.com', 36);
  INSERT INTO PERSONA VALUES (1170, 'Luciana', 'Villarroel', 'Molina', 

TO_DATE('1986-05-13', 'YYYY-MM-DD'), '6201170', '71221170', 'luciana.villarroel86@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1171, 'Bastian', 'Aguilera', 'Castro', TO_DATE('1999-10-21', 'YYYY-MM-DD'), '9301171', '68121171', 'bastian.aguilera.99@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1172, 'Isidora', 'Soria', 'Vega', TO_DATE('1984-02-29', 'YYYY-MM-DD'), '5401172', '71521172', 'isidora.soria84@hotmail.com', 42);
  INSERT INTO PERSONA VALUES (1173, 'Román', 'Balderrama', 'Delgado', TO_DATE('2002-07-09', 'YYYY-MM-DD'), '13501173', '75021173', 'roman.balde.02@gmail.com', 23);
  INSERT INTO PERSONA VALUES (1174, 'Amelia', 'Guevara', 'Guzmán', TO_DATE('1992-11-17', 'YYYY-MM-DD'), '8601174', '77021174', 'amelia.guevara92@gmail.com', 33);
  INSERT INTO PERSONA VALUES (1175, 'Ariel', 'Alba', 'Ramos', TO_DATE('1979-04-26', 'YYYY-MM-DD'), '4701175', '68021175', 'ariel.alba.79@yahoo.com', 47);
  INSERT INTO PERSONA VALUES (1176, 'Antonella', 'Cordero', 'Iglesias', TO_DATE('1996-09-03', 'YYYY-MM-DD'), '9801176', '71021176', 'anto.cordero96@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1177, 'Ulises', 'Becerra', 'Soto', TO_DATE('1982-01-12', 'YYYY-MM-DD'), '5901177', '65021177', 'ulises.becerra.82@hotmail.com', 44);
  INSERT INTO PERSONA VALUES (1178, 'Bianca', 'Salinas', 'Lara', TO_DATE('2000-06-21', 'YYYY-MM-DD'), '12001178', '76021178', 'bianca.salinas00@gmail.com', 25);
  INSERT INTO PERSONA VALUES (1179, 'León', 'Díaz', 'Márquez', TO_DATE('1988-10-30', 'YYYY-MM-DD'), '7101179', '77021179', 'leon.diaz.88@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1180, 'Guillermina', 'Romero', 'Luna', TO_DATE('1994-03-09', 'YYYY-MM-DD'), '8201180', '71221180', 'guille.romero94@hotmail.com', 32);
  INSERT INTO PERSONA VALUES (1181, 'Alejo', 'Blanco', 'Paz', TO_DATE('1980-07-18', 'YYYY-MM-DD'), '4301181', '68121181', 'alejo.blanco.80@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1182, 'Florencia', 'Rivas', 'León', TO_DATE('2003-12-26', 'YYYY-MM-DD'), '13401182', '71521182', 'flor.rivas03@gmail.com', 22);
  INSERT INTO PERSONA VALUES (1183, 'Elías', 'Paredes', 'Arias', TO_DATE('1991-05-05', 'YYYY-MM-DD'), '8501183', '75021183', 'elias.paredes.91@yahoo.com', 35);
  INSERT INTO PERSONA VALUES (1184, 'Maite', 'Navarro', 'Brito', TO_DATE('1985-09-13', 'YYYY-MM-DD'), '6601184', '77021184', 'maite.navarro85@hotmail.com', 40);
  INSERT INTO PERSONA VALUES (1185, 'Aarón', 'Soto', 'Vidal', TO_DATE('1998-02-22', 'YYYY-MM-DD'), '9701185', '68021185', 'aaron.soto.98@gmail.com', 28);
  INSERT INTO PERSONA VALUES (1186, 'Micaela', 'Molina', 'Escobar', TO_DATE('1983-07-02', 'YYYY-MM-DD'), '5801186', '71021186', 'micaela.molina83@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1187, 'Camilo', 'Campos', 'Acosta', TO_DATE('2001-11-10', 'YYYY-MM-DD'), '12901187', '65021187', 'camilo.campos.01@hotmail.com', 24);
  INSERT INTO PERSONA VALUES (1188, 'Celia', 'Vega', 'Reyes', TO_DATE('1990-03-20', 'YYYY-MM-DD'), '8001188', '76021188', 'celia.vega90@gmail.com', 36);
  INSERT INTO PERSONA VALUES (1189, 'Noel', 'Guzmán', 'Suárez', TO_DATE('1987-08-28', 'YYYY-MM-DD'), '6101189', '77021189', 'noel.guzman.87@gmail.com', 38);
  INSERT INTO PERSONA VALUES (1190, 'Violeta', 'Peña', 'Gil', TO_DATE('1995-01-06', 'YYYY-MM-DD'), '8201190', '71221190', 'violeta.pena95@yahoo.com', 31);
  INSERT INTO PERSONA VALUES (1191, 'Fidel', 'Mora', 'Rios', TO_DATE('1979-05-15', 'YYYY-MM-DD'), '4301191', '68121191', 'fidel.mora.79@hotmail.com', 46);
  INSERT INTO PERSONA VALUES (1192, 'Abril', 'Rey', 'Cano', TO_DATE('2000-09-23', 'YYYY-MM-DD'), '13401192', '71521192', 'abril.rey00@gmail.com', 25);
  INSERT INTO PERSONA VALUES (1193, 'Alex', 'Cruz', 'Nieto', TO_DATE('1993-02-01', 'YYYY-MM-DD'), '8501193', '75021193', 'alex.cruz.93@gmail.com', 33);
  INSERT INTO PERSONA VALUES (1194, 'Justina', 'Luna', 'Molina', TO_DATE('1984-06-11', 'YYYY-MM-DD'), '5601194', '77021194', 'justina.luna84@hotmail.com', 41);
  INSERT INTO PERSONA VALUES (1195, 'Oliver', 'Cabrera', 'Castro', TO_DATE('1999-10-19', 'YYYY-MM-DD'), '9701195', '68021195', 'oliver.cabrera.99@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1196, 'Miranda', 'Márquez', 'Vega', TO_DATE('1982-03-29', 'YYYY-MM-DD'), '5801196', '71021196', 'miranda.marquez82@gmail.com', 44);
  INSERT INTO PERSONA VALUES (1197, 'Enzo', 'Pino', 'Delgado', TO_DATE('2002-08-07', 'YYYY-MM-DD'), '12901197', '65021197', 'enzo.pino.02@yahoo.com', 23);
  INSERT INTO PERSONA VALUES (1198, 'Macarena', 'Salazar', 'Guzmán', TO_DATE('1992-12-16', 'YYYY-MM-DD'), '8001198', '76021198', 'maca.salazar92@hotmail.com', 33);
  INSERT INTO PERSONA VALUES (1199, 'Tobías', 'Vera', 'Ramos', TO_DATE('1978-04-25', 'YYYY-MM-DD'), '4101199', '77021199', 'tobias.vera.78@gmail.com', 48);
  INSERT INTO PERSONA VALUES (1200, 'Paulina', 'Gallo', 'Iglesias', TO_DATE('1996-09-03', 'YYYY-MM-DD'), '9201200', '71221200', 'paulina.gallo96@gmail.com', 29);
  COMMIT;
END;



BEGIN
  INSERT INTO PERSONA VALUES (1201, 'Kevin', 'Mamani', 'Quispe', TO_DATE('1995-10-15', 'YYYY-MM-DD'), '8301201', '71021201', 'kevin.mamani.95@gmail.com', 30);
  INSERT INTO PERSONA VALUES (1202, 'Evelyn', 'Condori', 'Pérez', TO_DATE('1990-04-12', 'YYYY-MM-DD'), '7401202', '60121202', 'evelyn.condori90@hotmail.com', 36);
  INSERT INTO PERSONA VALUES (1203, 'Rodrigo', 'Choque', 'Gómez', TO_DATE('1988-08-23', 'YYYY-MM-DD'), '6501203', '75021203', 'rodrigo.choque.88@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1204, 'Jessica', 'Rojas', 'Mendoza', TO_DATE('1999-01-05', 'YYYY-MM-DD'), '9601204', '77021204', 'jessica.rojas99@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1205, 'Christian', 'Vargas', 'Torres', TO_DATE('1985-11-30', 'YYYY-MM-DD'), '5701205', '68021205', 'christian.vargas.85@hotmail.com', 40);
  INSERT INTO PERSONA VALUES (1206, 'Diana', 'Flores', 'Silva', TO_DATE('1992-06-18', 'YYYY-MM-DD'), '8801206', '71521206', 'diana.flores92@gmail.com', 33);
  INSERT INTO PERSONA VALUES (1207, 'Oscar', 'Gutierrez', 'Castillo', TO_DATE('1980-03-25', 'YYYY-MM-DD'), '4901207', '65021207', 'oscar.gutierrez.80@yahoo.com', 46);
  INSERT INTO PERSONA VALUES (1208, 'Silvia', 'Apaza', 'Ruiz', TO_DATE('2001-09-14', 'YYYY-MM-DD'), '13001208', '76021208', 'silvia.apaza01@gmail.com', 24);
  INSERT INTO PERSONA VALUES (1209, 'Marcelo', 'Copana', 'Sánchez', TO_DATE('1997-05-10', 'YYYY-MM-DD'), '9101209', '77021209', 'marcelo.copana.97@gmail.com', 28);
  INSERT INTO PERSONA VALUES (1210, 'Karen', 'Callisaya', 'Martínez', TO_DATE('1986-12-02', 'YYYY-MM-DD'), '6201210', '71221210', 'karen.calli86@hotmail.com', 39);
  INSERT INTO PERSONA VALUES (1211, 'Pablo', 'Huanca', 'Ortiz', TO_DATE('1994-07-28', 'YYYY-MM-DD'), '8301211', '68121211', 'pablo.huanca.94@gmail.com', 31);
  INSERT INTO PERSONA VALUES (1212, 'Wendy', 'Ticona', 'Medina', TO_DATE('1983-02-16', 'YYYY-MM-DD'), '5401212', '71521212', 'wendy.ticona83@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1213, 'Javier', 'Arias', 'Cruz', TO_DATE('1998-10-09', 'YYYY-MM-DD'), '9501213', '75021213', 'javier.arias.98@hotmail.com', 27);
  INSERT INTO PERSONA VALUES (1214, 'Nadia', 'Poma', 'Ramírez', TO_DATE('2000-04-21', 'YYYY-MM-DD'), '12601214', '77021214', 'nadia.poma00@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1215, 'Mauricio', 'Cruz', 'Flores', TO_DATE('1977-12-11', 'YYYY-MM-DD'), '3701215', '68021215', 'mauricio.cruz.77@gmail.com', 48);
  INSERT INTO PERSONA VALUES (1216, 'Brenda', 'Machaca', 'Rojas', TO_DATE('1991-08-04', 'YYYY-MM-DD'), '8801216', '71021216', 'brenda.machaca91@yahoo.com', 34);
  INSERT INTO PERSONA VALUES (1217, 'Gustavo', 'Yujra', 'Vargas', TO_DATE('1984-01-17', 'YYYY-MM-DD'), '6901217', '65021217', 'gustavo.yujra.84@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1218, 'Erika', 'Lima', 'Choque', TO_DATE('1996-11-25', 'YYYY-MM-DD'), '9001218', '76021218', 'erika.lima96@hotmail.com', 29);
  INSERT INTO PERSONA VALUES (1219, 'Ricardo', 'Nina', 'Condori', TO_DATE('1981-06-08', 'YYYY-MM-DD'), '5101219', '77021219', 'ricardo.nina.81@gmail.com', 44);
  INSERT INTO PERSONA VALUES (1220, 'Pamela', 'Colque', 'Mamani', TO_DATE('2002-09-12', 'YYYY-MM-DD'), '13201220', '71221220', 'pamela.colque02@gmail.com', 23);
  INSERT INTO PERSONA VALUES (1221, 'Victor', 'Tarqui', 'Quispe', TO_DATE('1993-03-30', 'YYYY-MM-DD'), '8301221', '68121221', 'victor.tarqui.93@hotmail.com', 33);
  INSERT INTO PERSONA VALUES (1222, 'Cinthia', 'Aliaga', 'Apaza', TO_DATE('1987-10-14', 'YYYY-MM-DD'), '7401222', '71521222', 'cinthia.aliaga87@gmail.com', 38);
  INSERT INTO PERSONA VALUES (1223, 'Rolando', 'Mendoza', 'Huanca', TO_DATE('1998-05-27', 'YYYY-MM-DD'), '9501223', '75021223', 'rolando.mendoza.98@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1224, 'Shirley', 'Patzi', 'Ticona', TO_DATE('1982-12-05', 'YYYY-MM-DD'), '5601224', '77021224', 'shirley.patzi82@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1225, 'Nelson', 'Molina', 'Poma', TO_DATE('1995-07-19', 'YYYY-MM-DD'), '8701225', '68021225', 'nelson.molina.95@yahoo.com', 30);
  INSERT INTO PERSONA VALUES (1226, 'Ruth', 'Aruquipa', 'Cruz', TO_DATE('1999-02-01', 'YYYY-MM-DD'), '12801226', '71021226', 'ruth.aruquipa99@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1227, 'Julio', 'Chura', 'Machaca', TO_DATE('1976-09-22', 'YYYY-MM-DD'), '4901227', '65021227', 'julio.chura.76@hotmail.com', 49);
  INSERT INTO PERSONA VALUES (1228, 'Beatriz', 'Villca', 'Yujra', TO_DATE('1990-04-06', 'YYYY-MM-DD'), '8001228', '76021228', 'beatriz.villca90@gmail.com', 36);
  INSERT INTO PERSONA VALUES (1229, 'Armando', 'Guzmán', 'Lima', TO_DATE('1985-11-15', 'YYYY-MM-DD'), '6101229', '77021229', 'armando.guzman.85@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1230, 'Gladys', 'Siles', 'Nina', TO_DATE('1996-06-29', 'YYYY-MM-DD'), '9201230', '71221230', 'gladys.siles96@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1231, 'Edgar', 'Paredes', 'Colque', TO_DATE('1981-01-11', 'YYYY-MM-DD'), '5301231', '68121231', 'edgar.paredes.81@hotmail.com', 45);
  INSERT INTO PERSONA VALUES (1232, 'Cecilia', 'Cáceres', 'Tarqui', TO_DATE('2001-08-24', 'YYYY-MM-DD'), '13401232', '71521232', 'cecilia.caceres01@gmail.com', 24);
  INSERT INTO PERSONA VALUES (1233, 'Ivan', 'Orellana', 'Aliaga', TO_DATE('1989-03-08', 'YYYY-MM-DD'), '8501233', '75021233', 'ivan.orellana.89@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1234, 'Jimena', 'Ríos', 'Patzi', TO_DATE('1986-10-21', 'YYYY-MM-DD'), '6601234', '77021234', 'jimena.rios86@yahoo.com', 39);
  INSERT INTO PERSONA VALUES (1235, 'Ruben', 'Aguilar', 'Aruquipa', TO_DATE('1997-05-04', 'YYYY-MM-DD'), '9701235', '68021235', 'ruben.aguilar.97@gmail.com', 28);
  INSERT INTO PERSONA VALUES (1236, 'Sonia', 'Salazar', 'Chura', TO_DATE('1979-12-17', 'YYYY-MM-DD'), '4801236', '71021236', 'sonia.salazar79@gmail.com', 46);
  INSERT INTO PERSONA VALUES (1237, 'Eduardo', 'Miranda', 'Villca', TO_DATE('1992-07-02', 'YYYY-MM-DD'), '8901237', '65021237', 'eduardo.miranda.92@hotmail.com', 33);
  INSERT INTO PERSONA VALUES (1238, 'Marlene', 'Arce', 'Guzmán', TO_DATE('2000-02-14', 'YYYY-MM-DD'), '13001238', '76021238', 'marlene.arce00@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1239, 'Marco', 'Pacheco', 'Siles', TO_DATE('1984-09-27', 'YYYY-MM-DD'), '6101239', '77021239', 'marco.pacheco.84@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1240, 'Nelly', 'Vera', 'Paredes', TO_DATE('1995-04-10', 'YYYY-MM-DD'), '9201240', '71221240', 'nelly.vera95@hotmail.com', 31);
  INSERT INTO PERSONA VALUES (1241, 'Alvaro', 'Encinas', 'Cáceres', TO_DATE('1978-11-23', 'YYYY-MM-DD'), '4301241', '68121241', 'alvaro.encinas.78@gmail.com', 47);
  INSERT INTO PERSONA VALUES (1242, 'Tania', 'Escobar', 'Orellana', TO_DATE('1990-06-07', 'YYYY-MM-DD'), '8401242', '71521242', 'tania.escobar90@gmail.com', 35);
  INSERT INTO PERSONA VALUES (1243, 'Felix', 'Camacho', 'Ríos', TO_DATE('1999-01-19', 'YYYY-MM-DD'), '12501243', '75021243', 'felix.camacho.99@yahoo.com', 27);
  INSERT INTO PERSONA VALUES (1244, 'Irene', 'Sosa', 'Mamani', TO_DATE('1983-08-03', 'YYYY-MM-DD'), '5601244', '77021244', 'irene.sosa83@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1245, 'Guido', 'Lazo', 'Quispe', TO_DATE('1996-03-16', 'YYYY-MM-DD'), '9701245', '68021245', 'guido.lazo.96@hotmail.com', 30);
  INSERT INTO PERSONA VALUES (1246, 'Nancy', 'Cano', 'Choque', TO_DATE('1981-10-29', 'YYYY-MM-DD'), '5801246', '71021246', 'nancy.cano81@gmail.com', 44);
  INSERT INTO PERSONA VALUES (1247, 'Denis', 'Tapia', 'Condori', TO_DATE('1993-05-13', 'YYYY-MM-DD'), '8901247', '65021247', 'denis.tapia.93@gmail.com', 32);
  INSERT INTO PERSONA VALUES (1248, 'Rosario', 'Mora', 'Vargas', TO_DATE('2002-12-26', 'YYYY-MM-DD'), '13001248', '76021248', 'rosario.mora02@hotmail.com', 23);
  INSERT INTO PERSONA VALUES (1249, 'Hugo', 'Montoya', 'Flores', TO_DATE('1988-07-09', 'YYYY-MM-DD'), '7101249', '77021249', 'hugo.montoya.88@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1250, 'Paola', 'Serrano', 'Gutierrez', TO_DATE('1998-02-21', 'YYYY-MM-DD'), '9201250', '71221250', 'paola.serrano98@gmail.com', 28);
  INSERT INTO PERSONA VALUES (1251, 'Esteban', 'Coronel', 'Apaza', TO_DATE('1980-09-04', 'YYYY-MM-DD'), '5301251', '68121251', 'esteban.coronel.80@yahoo.com', 45);
  INSERT INTO PERSONA VALUES (1252, 'Lidia', 'Crespo', 'Copana', TO_DATE('1994-04-18', 'YYYY-MM-DD'), '8401252', '71521252', 'lidia.crespo94@gmail.com', 32);
  INSERT INTO PERSONA VALUES (1253, 'René', 'Delgado', 'Callisaya', TO_DATE('2001-11-30', 'YYYY-MM-DD'), '13501253', '75021253', 'rene.delgado.01@hotmail.com', 24);
  INSERT INTO PERSONA VALUES (1254, 'Norma', 'Pinto', 'Huanca', TO_DATE('1986-06-14', 'YYYY-MM-DD'), '6601254', '77021254', 'norma.pinto86@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1255, 'Alex', 'Salinas', 'Ticona', TO_DATE('1992-01-26', 'YYYY-MM-DD'), '8701255', '68021255', 'alex.salinas.92@gmail.com', 34);
  INSERT INTO PERSONA VALUES (1256, 'Blanca', 'Vallejos', 'Poma', TO_DATE('1979-08-10', 'YYYY-MM-DD'), '4801256', '71021256', 'blanca.vallejos79@hotmail.com', 46);
  INSERT INTO PERSONA VALUES (1257, 'Arturo', 'Carrillo', 'Cruz', TO_DATE('1997-03-24', 'YYYY-MM-DD'), '9901257', '65021257', 'arturo.carrillo.97@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1258, 'Marta', 'Velasco', 'Machaca', TO_DATE('1984-10-06', 'YYYY-MM-DD'), '6001258', '76021258', 'marta.velasco84@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1259, 'Grover', 'Huarachi', 'Yujra', TO_DATE('2000-05-20', 'YYYY-MM-DD'), '13101259', '77021259', 'grover.huarachi.00@yahoo.com', 25);
  INSERT INTO PERSONA VALUES (1260, 'Juana', 'Peña', 'Lima', TO_DATE('1990-12-03', 'YYYY-MM-DD'), '8201260', '71221260', 'juana.pena90@gmail.com', 35);
  INSERT INTO PERSONA VALUES (1261, 'Mario', 'Zarate', 'Nina', TO_DATE('1978-07-17', 'YYYY-MM-DD'), '4301261', '68121261', 'mario.zarate.78@hotmail.com', 47);
  INSERT INTO PERSONA VALUES (1262, 'Alicia', 'Chávez', 'Colque', TO_DATE('1995-02-28', 'YYYY-MM-DD'), '9401262', '71521262', 'alicia.chavez95@gmail.com', 31);
  INSERT INTO PERSONA VALUES (1263, 'Edwin', 'Montero', 'Tarqui', TO_DATE('1982-10-12', 'YYYY-MM-DD'), '5501263', '75021263', 'edwin.montero.82@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1264, 'Jenny', 'Lora', 'Aliaga', TO_DATE('1999-05-26', 'YYYY-MM-DD'), '12601264', '77021264', 'jenny.lora99@hotmail.com', 26);
  INSERT INTO PERSONA VALUES (1265, 'Saul', 'Bustamante', 'Mendoza', TO_DATE('1987-01-08', 'YYYY-MM-DD'), '7701265', '68021265', 'saul.bustamante.87@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1266, 'Doris', 'Cárdenas', 'Patzi', TO_DATE('1993-08-22', 'YYYY-MM-DD'), '8801266', '71021266', 'doris.cardenas93@gmail.com', 32);
  INSERT INTO PERSONA VALUES (1267, 'Fabián', 'Maclean', 'Molina', TO_DATE('1980-04-05', 'YYYY-MM-DD'), '5901267', '65021267', 'fabian.maclean.80@yahoo.com', 46);
  INSERT INTO PERSONA VALUES (1268, 'Julia', 'Roca', 'Aruquipa', TO_DATE('2002-11-18', 'YYYY-MM-DD'), '13001268', '76021268', 'julia.roca02@gmail.com', 23);
  INSERT INTO PERSONA VALUES (1269, 'Elio', 'Villarroel', 'Chura', TO_DATE('1989-06-02', 'YYYY-MM-DD'), '8101269', '77021269', 'elio.villarroel.89@hotmail.com', 36);
  INSERT INTO PERSONA VALUES (1270, 'Griselda', 'Aguilera', 'Villca', TO_DATE('1985-01-15', 'YYYY-MM-DD'), '6201270', '71221270', 'griselda.aguilera85@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1271, 'Boris', 'Soria', 'Guzmán', TO_DATE('1998-08-29', 'YYYY-MM-DD'), '9301271', '68121271', 'boris.soria.98@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1272, 'Monica', 'Balderrama', 'Siles', TO_DATE('1983-04-13', 'YYYY-MM-DD'), '5401272', '71521272', 'monica.balde83@hotmail.com', 43);
  INSERT INTO PERSONA VALUES (1273, 'Gaston', 'Guevara', 'Paredes', TO_DATE('2001-11-26', 'YYYY-MM-DD'), '13501273', '75021273', 'gaston.guevara.01@gmail.com', 24);
  INSERT INTO PERSONA VALUES (1274, 'Yolanda', 'Alba', 'Cáceres', TO_DATE('1991-07-10', 'YYYY-MM-DD'), '8601274', '77021274', 'yolanda.alba91@gmail.com', 34);
  INSERT INTO PERSONA VALUES (1275, 'Richard', 'Cordero', 'Orellana', TO_DATE('1978-02-22', 'YYYY-MM-DD'), '4701275', '68021275', 'richard.cordero.78@yahoo.com', 48);
  INSERT INTO PERSONA VALUES (1276, 'Fabiola', 'Becerra', 'Ríos', TO_DATE('1995-10-06', 'YYYY-MM-DD'), '9801276', '71021276', 'fabiola.becerra95@gmail.com', 30);
  INSERT INTO PERSONA VALUES (1277, 'Marcelo', 'Salinas', 'Aguilar', TO_DATE('1981-05-20', 'YYYY-MM-DD'), '5901277', '65021277', 'marcelo.salinas.81@hotmail.com', 44);
  INSERT INTO PERSONA VALUES (1278, 'Carla', 'Díaz', 'Salazar', TO_DATE('1999-12-03', 'YYYY-MM-DD'), '12001278', '76021278', 'carla.diaz99@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1279, 'Sergio', 'Romero', 'Miranda', TO_DATE('1987-07-17', 'YYYY-MM-DD'), '7101279', '77021279', 'sergio.romero.87@gmail.com', 38);
  INSERT INTO PERSONA VALUES (1280, 'Lizeth', 'Blanco', 'Arce', TO_DATE('1993-02-28', 'YYYY-MM-DD'), '8201280', '71221280', 'lizeth.blanco93@hotmail.com', 33);
  INSERT INTO PERSONA VALUES (1281, 'Erick', 'Rivas', 'Pacheco', TO_DATE('1979-10-13', 'YYYY-MM-DD'), '4301281', '68121281', 'erick.rivas.79@gmail.com', 46);
  INSERT INTO PERSONA VALUES (1282, 'Vania', 'Paredes', 'Vera', TO_DATE('2002-05-27', 'YYYY-MM-DD'), '13401282', '71521282', 'vania.paredes02@gmail.com', 23);
  INSERT INTO PERSONA VALUES (1283, 'Johnny', 'Navarro', 'Encinas', TO_DATE('1990-01-09', 'YYYY-MM-DD'), '8501283', '75021283', 'johnny.navarro.90@yahoo.com', 36);
  INSERT INTO PERSONA VALUES (1284, 'Dayana', 'Soto', 'Escobar', TO_DATE('1984-08-23', 'YYYY-MM-DD'), '6601284', '77021284', 'dayana.soto84@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1285, 'Wilson', 'Molina', 'Camacho', TO_DATE('1997-04-06', 'YYYY-MM-DD'), '9701285', '68021285', 'wilson.molina.97@hotmail.com', 29);
  INSERT INTO PERSONA VALUES (1286, 'Noelia', 'Campos', 'Sosa', TO_DATE('1982-11-19', 'YYYY-MM-DD'), '5801286', '71021286', 'noelia.campos82@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1287, 'Ramiro', 'Vega', 'Lazo', TO_DATE('2000-07-03', 'YYYY-MM-DD'), '12901287', '65021287', 'ramiro.vega.00@gmail.com', 25);
  INSERT INTO PERSONA VALUES (1288, 'Estela', 'Guzmán', 'Cano', TO_DATE('1989-02-15', 'YYYY-MM-DD'), '8001288', '76021288', 'estela.guzman89@hotmail.com', 37);
  INSERT INTO PERSONA VALUES (1289, 'Omar', 'Peña', 'Tapia', TO_DATE('1986-09-29', 'YYYY-MM-DD'), '6101289', '77021289', 'omar.pena.86@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1290, 'Elva', 'Mora', 'Mora', TO_DATE('1994-05-13', 'YYYY-MM-DD'), '8201290', '71221290', 'elva.mora94@gmail.com', 31);
  INSERT INTO PERSONA VALUES (1291, 'Milton', 'Rey', 'Montoya', TO_DATE('1978-12-26', 'YYYY-MM-DD'), '4301291', '68121291', 'milton.rey.78@yahoo.com', 47);
  INSERT INTO PERSONA VALUES (1292, 'Lourdes', 'Cruz', 'Serrano', TO_DATE('1999-08-09', 'YYYY-MM-DD'), '13401292', '71521292', 'lourdes.cruz99@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1293, 'Ariel', 'Luna', 'Coronel', TO_DATE('1992-03-23', 'YYYY-MM-DD'), '8501293', '75021293', 'ariel.luna.92@hotmail.com', 34);
  INSERT INTO PERSONA VALUES (1294, 'Marcela', 'Cabrera', 'Crespo', TO_DATE('1983-10-06', 'YYYY-MM-DD'), '5601294', '77021294', 'marcela.cabrera83@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1295, 'Cristian', 'Márquez', 'Delgado', TO_DATE('1998-05-20', 'YYYY-MM-DD'), '9701295', '68021295', 'cristian.marquez.98@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1296, 'Ester', 'Pino', 'Pinto', TO_DATE('1981-12-03', 'YYYY-MM-DD'), '5801296', '71021296', 'ester.pino81@hotmail.com', 44);
  INSERT INTO PERSONA VALUES (1297, 'Franklin', 'Salazar', 'Salinas', TO_DATE('2001-07-17', 'YYYY-MM-DD'), '12901297', '65021297', 'franklin.salazar.01@gmail.com', 24);
  INSERT INTO PERSONA VALUES (1298, 'Raquel', 'Vera', 'Vallejos', TO_DATE('1991-02-28', 'YYYY-MM-DD'), '8001298', '76021298', 'raquel.vera91@gmail.com', 35);
  INSERT INTO PERSONA VALUES (1299, 'Boris', 'Gallo', 'Carrillo', TO_DATE('1977-10-13', 'YYYY-MM-DD'), '4101299', '77021299', 'boris.gallo.77@yahoo.com', 48);
  INSERT INTO PERSONA VALUES (1300, 'Ximena', 'Molina', 'Velasco', TO_DATE('1995-05-27', 'YYYY-MM-DD'), '9201300', '71221300', 'ximena.molina95@gmail.com', 30);
  COMMIT;
END;



BEGIN
  INSERT INTO PERSONA VALUES (1301, 'Juan', 'Mamani', 'Machaca', TO_DATE('1990-05-14', 'YYYY-MM-DD'), '5101301', '71011301', 'juan.mamani.1301@gmail.com', 36);
  INSERT INTO PERSONA VALUES (1302, 'Maria', 'Quispe', 'Yujra', TO_DATE('1985-08-21', 'YYYY-MM-DD'), '5101302', '71011302', 'maria.quispe.1302@hotmail.com', 40);
  INSERT INTO PERSONA VALUES (1303, 'Carlos', 'Choque', 'Nina', TO_DATE('1992-11-03', 'YYYY-MM-DD'), '5101303', '71011303', 'carlos.choque.1303@gmail.com', 33);
  INSERT INTO PERSONA VALUES (1304, 'Ana', 'Condori', 'Colque', TO_DATE('1998-02-15', 'YYYY-MM-DD'), '5101304', '71011304', 'ana.condori.1304@yahoo.com', 28);
  INSERT INTO PERSONA VALUES (1305, 'Luis', 'Rojas', 'Tarqui', TO_DATE('1980-07-09', 'YYYY-MM-DD'), '5101305', '71011305', 'luis.rojas.1305@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1306, 'Laura', 'Flores', 'Aliaga', TO_DATE('2001-04-26', 'YYYY-MM-DD'), '5101306', '71011306', 'laura.flores.1306@gmail.com', 25);
  INSERT INTO PERSONA VALUES (1307, 'Diego', 'Vargas', 'Huanca', TO_DATE('1995-09-12', 'YYYY-MM-DD'), '5101307', '71011307', 'diego.vargas.1307@hotmail.com', 30);
  INSERT INTO PERSONA VALUES (1308, 'Gabriela', 'Mendoza', 'Ticona', TO_DATE('1988-12-30', 'YYYY-MM-DD'), '5101308', '71011308', 'gaby.mendoza.1308@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1309, 'Jorge', 'Gutierrez', 'Arias', TO_DATE('1975-03-18', 'YYYY-MM-DD'), '5101309', '71011309', 'jorge.gutierrez.1309@yahoo.com', 51);
  INSERT INTO PERSONA VALUES (1310, 'Elena', 'Apaza', 'Poma', TO_DATE('1999-06-22', 'YYYY-MM-DD'), '5101310', '71011310', 'elena.apaza.1310@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1311, 'Miguel', 'Copana', 'Cruz', TO_DATE('1982-10-05', 'YYYY-MM-DD'), '5101311', '71011311', 'miguel.copana.1311@hotmail.com', 43);
  INSERT INTO PERSONA VALUES (1312, 'Carmen', 'Machaca', 'Lima', TO_DATE('1994-01-14', 'YYYY-MM-DD'), '5101312', '71011312', 'carmen.machaca.1312@gmail.com', 32);
  INSERT INTO PERSONA VALUES (1313, 'Fernando', 'Yujra', 'Aruquipa', TO_DATE('1987-05-28', 'YYYY-MM-DD'), '5101313', '71011313', 'fer.yujra.1313@gmail.com', 38);
  INSERT INTO PERSONA VALUES (1314, 'Daniela', 'Pinto', 'Chura', TO_DATE('2000-08-11', 'YYYY-MM-DD'), '5101314', '71011314', 'dani.pinto.1314@yahoo.com', 25);
  INSERT INTO PERSONA VALUES (1315, 'Jose', 'Nina', 'Villca', TO_DATE('1978-11-25', 'YYYY-MM-DD'), '5101315', '71011315', 'jose.nina.1315@gmail.com', 47);
  INSERT INTO PERSONA VALUES (1316, 'Rosa', 'Colque', 'Siles', TO_DATE('1991-02-08', 'YYYY-MM-DD'), '5101316', '71011316', 'rosa.colque.1316@hotmail.com', 35);
  INSERT INTO PERSONA VALUES (1317, 'Pedro', 'Tarqui', 'Caceres', TO_DATE('1986-07-19', 'YYYY-MM-DD'), '5101317', '71011317', 'pedro.tarqui.1317@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1318, 'Lucia', 'Aliaga', 'Orellana', TO_DATE('1997-10-02', 'YYYY-MM-DD'), '5101318', '71011318', 'lucia.aliaga.1318@gmail.com', 28);
  INSERT INTO PERSONA VALUES (1319, 'Roberto', 'Huanca', 'Mamani', TO_DATE('1983-04-16', 'YYYY-MM-DD'), '5101319', '71011319', 'roberto.huanca.1319@yahoo.com', 43);
  INSERT INTO PERSONA VALUES (1320, 'Sonia', 'Ticona', 'Quispe', TO_DATE('1996-09-29', 'YYYY-MM-DD'), '5101320', '71011320', 'sonia.ticona.1320@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1321, 'Andres', 'Arias', 'Choque', TO_DATE('1979-12-10', 'YYYY-MM-DD'), '5101321', '71011321', 'andres.arias.1321@hotmail.com', 46);
  INSERT INTO PERSONA VALUES (1322, 'Paola', 'Poma', 'Condori', TO_DATE('2002-03-24', 'YYYY-MM-DD'), '5101322', '71011322', 'paola.poma.1322@gmail.com', 24);
  INSERT INTO PERSONA VALUES (1323, 'Marcelo', 'Cruz', 'Rojas', TO_DATE('1989-06-07', 'YYYY-MM-DD'), '5101323', '71011323', 'marcelo.cruz.1323@gmail.com', 36);
  INSERT INTO PERSONA VALUES (1324, 'Jimena', 'Lima', 'Flores', TO_DATE('1993-11-20', 'YYYY-MM-DD'), '5101324', '71011324', 'jimena.lima.1324@yahoo.com', 32);
  INSERT INTO PERSONA VALUES (1325, 'Victor', 'Aruquipa', 'Vargas', TO_DATE('1981-01-04', 'YYYY-MM-DD'), '5101325', '71011325', 'victor.aruquipa.1325@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1326, 'Beatriz', 'Chura', 'Mendoza', TO_DATE('1998-05-18', 'YYYY-MM-DD'), '5101326', '71011326', 'beatriz.chura.1326@hotmail.com', 27);
  INSERT INTO PERSONA VALUES (1327, 'Gonzalo', 'Villca', 'Gutierrez', TO_DATE('1976-08-31', 'YYYY-MM-DD'), '5101327', '71011327', 'gonzalo.villca.1327@gmail.com', 49);
  INSERT INTO PERSONA VALUES (1328, 'Teresa', 'Siles', 'Apaza', TO_DATE('2000-12-14', 'YYYY-MM-DD'), '5101328', '71011328', 'teresa.siles.1328@gmail.com', 25);
  INSERT INTO PERSONA VALUES (1329, 'Ruben', 'Caceres', 'Copana', TO_DATE('1984-02-27', 'YYYY-MM-DD'), '5101329', '71011329', 'ruben.caceres.1329@yahoo.com', 42);
  INSERT INTO PERSONA VALUES (1330, 'Silvia', 'Orellana', 'Machaca', TO_DATE('1995-07-11', 'YYYY-MM-DD'), '5101330', '71011330', 'silvia.orellana.1330@gmail.com', 30);
  INSERT INTO PERSONA VALUES (1331, 'Eduardo', 'Rios', 'Yujra', TO_DATE('1977-10-24', 'YYYY-MM-DD'), '5101331', '71011331', 'eduardo.rios.1331@hotmail.com', 48);
  INSERT INTO PERSONA VALUES (1332, 'Marcela', 'Aguilar', 'Pinto', TO_DATE('1991-01-06', 'YYYY-MM-DD'), '5101332', '71011332', 'marcela.aguilar.1332@gmail.com', 35);
  INSERT INTO PERSONA VALUES (1333, 'Ivan', 'Salazar', 'Nina', TO_DATE('1988-04-20', 'YYYY-MM-DD'), '5101333', '71011333', 'ivan.salazar.1333@gmail.com', 38);
  INSERT INTO PERSONA VALUES (1334, 'Claudia', 'Miranda', 'Colque', TO_DATE('1999-09-02', 'YYYY-MM-DD'), '5101334', '71011334', 'claudia.miranda.1334@yahoo.com', 26);
  INSERT INTO PERSONA VALUES (1335, 'Raul', 'Arce', 'Tarqui', TO_DATE('1982-12-16', 'YYYY-MM-DD'), '5101335', '71011335', 'raul.arce.1335@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1336, 'Monica', 'Pacheco', 'Aliaga', TO_DATE('1994-03-29', 'YYYY-MM-DD'), '5101336', '71011336', 'monica.pacheco.1336@hotmail.com', 32);
  INSERT INTO PERSONA VALUES (1337, 'Alejandro', 'Vera', 'Huanca', TO_DATE('1979-06-12', 'YYYY-MM-DD'), '5101337', '71011337', 'alejandro.vera.1337@gmail.com', 46);
  INSERT INTO PERSONA VALUES (1338, 'Alicia', 'Encinas', 'Ticona', TO_DATE('2003-10-25', 'YYYY-MM-DD'), '5101338', '71011338', 'alicia.encinas.1338@gmail.com', 22);
  INSERT INTO PERSONA VALUES (1339, 'Rolando', 'Escobar', 'Arias', TO_DATE('1985-01-08', 'YYYY-MM-DD'), '5101339', '71011339', 'rolando.escobar.1339@yahoo.com', 41);
  INSERT INTO PERSONA VALUES (1340, 'Jenny', 'Camacho', 'Poma', TO_DATE('1997-04-21', 'YYYY-MM-DD'), '5101340', '71011340', 'jenny.camacho.1340@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1341, 'Guillermo', 'Sosa', 'Cruz', TO_DATE('1980-08-04', 'YYYY-MM-DD'), '5101341', '71011341', 'guillermo.sosa.1341@hotmail.com', 45);
  INSERT INTO PERSONA VALUES (1342, 'Jessica', 'Lazo', 'Lima', TO_DATE('1992-11-17', 'YYYY-MM-DD'), '5101342', '71011342', 'jessica.lazo.1342@gmail.com', 33);
  INSERT INTO PERSONA VALUES (1343, 'Ramiro', 'Cano', 'Aruquipa', TO_DATE('1987-02-28', 'YYYY-MM-DD'), '5101343', '71011343', 'ramiro.cano.1343@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1344, 'Noelia', 'Tapia', 'Chura', TO_DATE('2000-06-12', 'YYYY-MM-DD'), '5101344', '71011344', 'noelia.tapia.1344@yahoo.com', 25);
  INSERT INTO PERSONA VALUES (1345, 'Felix', 'Mora', 'Villca', TO_DATE('1976-09-25', 'YYYY-MM-DD'), '5101345', '71011345', 'felix.mora.1345@gmail.com', 49);
  INSERT INTO PERSONA VALUES (1346, 'Evelyn', 'Montoya', 'Siles', TO_DATE('1995-12-08', 'YYYY-MM-DD'), '5101346', '71011346', 'evelyn.montoya.1346@hotmail.com', 30);
  INSERT INTO PERSONA VALUES (1347, 'Arturo', 'Serrano', 'Caceres', TO_DATE('1983-03-22', 'YYYY-MM-DD'), '5101347', '71011347', 'arturo.serrano.1347@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1348, 'Pamela', 'Coronel', 'Orellana', TO_DATE('1998-07-05', 'YYYY-MM-DD'), '5101348', '71011348', 'pamela.coronel.1348@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1349, 'Rodrigo', 'Crespo', 'Mamani', TO_DATE('1981-10-18', 'YYYY-MM-DD'), '5101349', '71011349', 'rodrigo.crespo.1349@yahoo.com', 44);
  INSERT INTO PERSONA VALUES (1350, 'Diana', 'Delgado', 'Quispe', TO_DATE('2001-01-31', 'YYYY-MM-DD'), '5101350', '71011350', 'diana.delgado.1350@gmail.com', 25);
  INSERT INTO PERSONA VALUES (1351, 'Oscar', 'Pinto', 'Choque', TO_DATE('1989-05-15', 'YYYY-MM-DD'), '5101351', '71011351', 'oscar.pinto.1351@hotmail.com', 36);
  INSERT INTO PERSONA VALUES (1352, 'Nadia', 'Salinas', 'Condori', TO_DATE('1996-08-27', 'YYYY-MM-DD'), '5101352', '71011352', 'nadia.salinas.1352@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1353, 'Marcelo', 'Vallejos', 'Rojas', TO_DATE('1978-12-10', 'YYYY-MM-DD'), '5101353', '71011353', 'marcelo.vallejos.1353@gmail.com', 47);
  INSERT INTO PERSONA VALUES (1354, 'Karen', 'Carrillo', 'Flores', TO_DATE('1991-03-24', 'YYYY-MM-DD'), '5101354', '71011354', 'karen.carrillo.1354@yahoo.com', 35);
  INSERT INTO PERSONA VALUES (1355, 'Hugo', 'Velasco', 'Vargas', TO_DATE('1986-06-06', 'YYYY-MM-DD'), '5101355', '71011355', 'hugo.velasco.1355@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1356, 'Lidia', 'Huarachi', 'Gutierrez', TO_DATE('1999-09-19', 'YYYY-MM-DD'), '5101356', '71011356', 'lidia.huarachi.1356@hotmail.com', 26);
  INSERT INTO PERSONA VALUES (1357, 'Rene', 'Peña', 'Mendoza', TO_DATE('1982-12-02', 'YYYY-MM-DD'), '5101357', '71011357', 'rene.pena.1357@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1358, 'Norma', 'Zarate', 'Apaza', TO_DATE('1994-04-16', 'YYYY-MM-DD'), '5101358', '71011358', 'norma.zarate.1358@gmail.com', 32);
  INSERT INTO PERSONA VALUES (1359, 'Alex', 'Chavez', 'Copana', TO_DATE('1977-07-29', 'YYYY-MM-DD'), '5101359', '71011359', 'alex.chavez.1359@yahoo.com', 48);
  INSERT INTO PERSONA VALUES (1360, 'Blanca', 'Montero', 'Machaca', TO_DATE('2002-11-11', 'YYYY-MM-DD'), '5101360', '71011360', 'blanca.montero.1360@gmail.com', 23);
  INSERT INTO PERSONA VALUES (1361, 'Arturo', 'Lora', 'Yujra', TO_DATE('1985-02-23', 'YYYY-MM-DD'), '5101361', '71011361', 'arturo.lora.1361@hotmail.com', 41);
  INSERT INTO PERSONA VALUES (1362, 'Marta', 'Bustamante', 'Pinto', TO_DATE('1997-06-07', 'YYYY-MM-DD'), '5101362', '71011362', 'marta.bustamante.1362@gmail.com', 28);
  INSERT INTO PERSONA VALUES (1363, 'Grover', 'Cardenas', 'Nina', TO_DATE('1980-09-20', 'YYYY-MM-DD'), '5101363', '71011363', 'grover.cardenas.1363@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1364, 'Juana', 'Maclean', 'Colque', TO_DATE('1993-12-03', 'YYYY-MM-DD'), '5101364', '71011364', 'juana.maclean.1364@yahoo.com', 32);
  INSERT INTO PERSONA VALUES (1365, 'Mario', 'Roca', 'Tarqui', TO_DATE('1988-03-17', 'YYYY-MM-DD'), '5101365', '71011365', 'mario.roca.1365@gmail.com', 38);
  INSERT INTO PERSONA VALUES (1366, 'Cinthia', 'Villarroel', 'Aliaga', TO_DATE('2000-06-30', 'YYYY-MM-DD'), '5101366', '71011366', 'cinthia.villarroel.1366@hotmail.com', 25);
  INSERT INTO PERSONA VALUES (1367, 'Edwin', 'Aguilera', 'Huanca', TO_DATE('1975-10-13', 'YYYY-MM-DD'), '5101367', '71011367', 'edwin.aguilera.1367@gmail.com', 50);
  INSERT INTO PERSONA VALUES (1368, 'Saul', 'Soria', 'Ticona', TO_DATE('1996-01-26', 'YYYY-MM-DD'), '5101368', '71011368', 'saul.soria.1368@gmail.com', 30);
  INSERT INTO PERSONA VALUES (1369, 'Doris', 'Balderrama', 'Arias', TO_DATE('1983-05-10', 'YYYY-MM-DD'), '5101369', '71011369', 'doris.balderrama.1369@yahoo.com', 42);
  INSERT INTO PERSONA VALUES (1370, 'Fabian', 'Guevara', 'Poma', TO_DATE('1998-08-23', 'YYYY-MM-DD'), '5101370', '71011370', 'fabian.guevara.1370@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1371, 'Julia', 'Alba', 'Cruz', TO_DATE('1981-11-05', 'YYYY-MM-DD'), '5101371', '71011371', 'julia.alba.1371@hotmail.com', 44);
  INSERT INTO PERSONA VALUES (1372, 'Elio', 'Cordero', 'Lima', TO_DATE('1994-02-18', 'YYYY-MM-DD'), '5101372', '71011372', 'elio.cordero.1372@gmail.com', 32);
  INSERT INTO PERSONA VALUES (1373, 'Griselda', 'Becerra', 'Aruquipa', TO_DATE('1978-06-02', 'YYYY-MM-DD'), '5101373', '71011373', 'griselda.becerra.1373@gmail.com', 47);
  INSERT INTO PERSONA VALUES (1374, 'Boris', 'Salinas', 'Chura', TO_DATE('1991-09-15', 'YYYY-MM-DD'), '5101374', '71011374', 'boris.salinas.1374@yahoo.com', 34);
  INSERT INTO PERSONA VALUES (1375, 'Monica', 'Diaz', 'Villca', TO_DATE('1986-12-28', 'YYYY-MM-DD'), '5101375', '71011375', 'monica.diaz.1375@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1376, 'Gaston', 'Romero', 'Siles', TO_DATE('2001-04-11', 'YYYY-MM-DD'), '5101376', '71011376', 'gaston.romero.1376@hotmail.com', 24);
  INSERT INTO PERSONA VALUES (1377, 'Yolanda', 'Blanco', 'Caceres', TO_DATE('1976-07-25', 'YYYY-MM-DD'), '5101377', '71011377', 'yolanda.blanco.1377@gmail.com', 49);
  INSERT INTO PERSONA VALUES (1378, 'Richard', 'Rivas', 'Orellana', TO_DATE('1995-10-08', 'YYYY-MM-DD'), '5101378', '71011378', 'richard.rivas.1378@gmail.com', 30);
  INSERT INTO PERSONA VALUES (1379, 'Fabiola', 'Paredes', 'Mamani', TO_DATE('1980-01-20', 'YYYY-MM-DD'), '5101379', '71011379', 'fabiola.paredes.1379@yahoo.com', 46);
  INSERT INTO PERSONA VALUES (1380, 'Marcelo', 'Navarro', 'Quispe', TO_DATE('1998-05-04', 'YYYY-MM-DD'), '5101380', '71011380', 'marcelo.navarro.1380@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1381, 'Carla', 'Soto', 'Choque', TO_DATE('1983-08-17', 'YYYY-MM-DD'), '5101381', '71011381', 'carla.soto.1381@hotmail.com', 42);
  INSERT INTO PERSONA VALUES (1382, 'Sergio', 'Molina', 'Condori', TO_DATE('1996-11-30', 'YYYY-MM-DD'), '5101382', '71011382', 'sergio.molina.1382@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1383, 'Lizeth', 'Campos', 'Rojas', TO_DATE('1979-03-14', 'YYYY-MM-DD'), '5101383', '71011383', 'lizeth.campos.1383@gmail.com', 47);
  INSERT INTO PERSONA VALUES (1384, 'Erick', 'Vega', 'Flores', TO_DATE('1992-06-27', 'YYYY-MM-DD'), '5101384', '71011384', 'erick.vega.1384@yahoo.com', 33);
  INSERT INTO PERSONA VALUES (1385, 'Vania', 'Guzman', 'Vargas', TO_DATE('1987-10-10', 'YYYY-MM-DD'), '5101385', '71011385', 'vania.guzman.1385@gmail.com', 38);
  INSERT INTO PERSONA VALUES (1386, 'Johnny', 'Peña', 'Gutierrez', TO_DATE('2000-01-23', 'YYYY-MM-DD'), '5101386', '71011386', 'johnny.pena.1386@hotmail.com', 26);
  INSERT INTO PERSONA VALUES (1387, 'Dayana', 'Mora', 'Mendoza', TO_DATE('1977-05-07', 'YYYY-MM-DD'), '5101387', '71011387', 'dayana.mora.1387@gmail.com', 48);
  INSERT INTO PERSONA VALUES (1388, 'Wilson', 'Rey', 'Apaza', TO_DATE('1994-08-20', 'YYYY-MM-DD'), '5101388', '71011388', 'wilson.rey.1388@gmail.com', 31);
  INSERT INTO PERSONA VALUES (1389, 'Noelia', 'Cruz', 'Copana', TO_DATE('1982-11-02', 'YYYY-MM-DD'), '5101389', '71011389', 'noelia.cruz.1389@yahoo.com', 43);
  INSERT INTO PERSONA VALUES (1390, 'Ramiro', 'Luna', 'Machaca', TO_DATE('1999-02-15', 'YYYY-MM-DD'), '5101390', '71011390', 'ramiro.luna.1390@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1391, 'Estela', 'Cabrera', 'Yujra', TO_DATE('1984-05-30', 'YYYY-MM-DD'), '5101391', '71011391', 'estela.cabrera.1391@hotmail.com', 41);
  INSERT INTO PERSONA VALUES (1392, 'Omar', 'Marquez', 'Pinto', TO_DATE('1997-09-12', 'YYYY-MM-DD'), '5101392', '71011392', 'omar.marquez.1392@gmail.com', 28);
  INSERT INTO PERSONA VALUES (1393, 'Elva', 'Pino', 'Nina', TO_DATE('1980-12-26', 'YYYY-MM-DD'), '5101393', '71011393', 'elva.pino.1393@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1394, 'Milton', 'Salazar', 'Colque', TO_DATE('1995-04-09', 'YYYY-MM-DD'), '5101394', '71011394', 'milton.salazar.1394@yahoo.com', 31);
  INSERT INTO PERSONA VALUES (1395, 'Lourdes', 'Vera', 'Tarqui', TO_DATE('1988-07-23', 'YYYY-MM-DD'), '5101395', '71011395', 'lourdes.vera.1395@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1396, 'Ariel', 'Gallo', 'Aliaga', TO_DATE('2002-10-06', 'YYYY-MM-DD'), '5101396', '71011396', 'ariel.gallo.1396@hotmail.com', 23);
  INSERT INTO PERSONA VALUES (1397, 'Marcela', 'Molina', 'Huanca', TO_DATE('1975-01-19', 'YYYY-MM-DD'), '5101397', '71011397', 'marcela.molina.1397@gmail.com', 51);
  INSERT INTO PERSONA VALUES (1398, 'Cristian', 'Cano', 'Ticona', TO_DATE('1993-05-03', 'YYYY-MM-DD'), '5101398', '71011398', 'cristian.cano.1398@gmail.com', 32);
  INSERT INTO PERSONA VALUES (1399, 'Ester', 'Tapia', 'Arias', TO_DATE('1985-08-16', 'YYYY-MM-DD'), '5101399', '71011399', 'ester.tapia.1399@yahoo.com', 40);
  INSERT INTO PERSONA VALUES (1400, 'Franklin', 'Mora', 'Poma', TO_DATE('1998-11-29', 'YYYY-MM-DD'), '5101400', '71011400', 'franklin.mora.1400@gmail.com', 27);
  COMMIT;
END;




BEGIN
  INSERT INTO PERSONA VALUES (1401, 'Raquel', 'Montoya', 'Cruz', TO_DATE('1981-03-13', 'YYYY-MM-DD'), '5101401', '71011401', 'raquel.montoya.1401@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1402, 'Ximena', 'Serrano', 'Lima', TO_DATE('1996-06-26', 'YYYY-MM-DD'), '5101402', '71011402', 'ximena.serrano.1402@hotmail.com', 29);
  INSERT INTO PERSONA VALUES (1403, 'Kevin', 'Coronel', 'Aruquipa', TO_DATE('1989-10-09', 'YYYY-MM-DD'), '5101403', '71011403', 'kevin.coronel.1403@gmail.com', 36);
  INSERT INTO PERSONA VALUES (1404, 'Evelyn', 'Crespo', 'Chura', TO_DATE('2001-01-22', 'YYYY-MM-DD'), '5101404', '71011404', 'evelyn.crespo.1404@yahoo.com', 25);
  INSERT INTO PERSONA VALUES (1405, 'Jessica', 'Delgado', 'Villca', TO_DATE('1978-05-07', 'YYYY-MM-DD'), '5101405', '71011405', 'jessica.delgado.1405@gmail.com', 47);
  INSERT INTO PERSONA VALUES (1406, 'Christian', 'Pinto', 'Siles', TO_DATE('1991-08-20', 'YYYY-MM-DD'), '5101406', '71011406', 'christian.pinto.1406@gmail.com', 34);
  INSERT INTO PERSONA VALUES (1407, 'Diana', 'Salinas', 'Caceres', TO_DATE('1984-12-03', 'YYYY-MM-DD'), '5101407', '71011407', 'diana.salinas.1407@hotmail.com', 41);
  INSERT INTO PERSONA VALUES (1408, 'Oscar', 'Vallejos', 'Orellana', TO_DATE('1999-03-17', 'YYYY-MM-DD'), '5101408', '71011408', 'oscar.vallejos.1408@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1409, 'Silvia', 'Carrillo', 'Mamani', TO_DATE('1982-06-30', 'YYYY-MM-DD'), '5101409', '71011409', 'silvia.carrillo.1409@yahoo.com', 43);
  INSERT INTO PERSONA VALUES (1410, 'Marcelo', 'Velasco', 'Quispe', TO_DATE('1994-10-13', 'YYYY-MM-DD'), '5101410', '71011410', 'marcelo.velasco.1410@gmail.com', 31);
  INSERT INTO PERSONA VALUES (1411, 'Karen', 'Huarachi', 'Choque', TO_DATE('1977-01-26', 'YYYY-MM-DD'), '5101411', '71011411', 'karen.huarachi.1411@gmail.com', 49);
  INSERT INTO PERSONA VALUES (1412, 'Pablo', 'Peña', 'Condori', TO_DATE('1990-05-11', 'YYYY-MM-DD'), '5101412', '71011412', 'pablo.pena.1412@hotmail.com', 35);
  INSERT INTO PERSONA VALUES (1413, 'Wendy', 'Zarate', 'Rojas', TO_DATE('1986-08-24', 'YYYY-MM-DD'), '5101413', '71011413', 'wendy.zarate.1413@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1414, 'Javier', 'Chavez', 'Flores', TO_DATE('2000-12-07', 'YYYY-MM-DD'), '5101414', '71011414', 'javier.chavez.1414@yahoo.com', 25);
  INSERT INTO PERSONA VALUES (1415, 'Nadia', 'Montero', 'Vargas', TO_DATE('1983-03-22', 'YYYY-MM-DD'), '5101415', '71011415', 'nadia.montero.1415@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1416, 'Mauricio', 'Lora', 'Gutierrez', TO_DATE('1996-07-05', 'YYYY-MM-DD'), '5101416', '71011416', 'mauricio.lora.1416@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1417, 'Brenda', 'Bustamante', 'Mendoza', TO_DATE('1979-10-18', 'YYYY-MM-DD'), '5101417', '71011417', 'brenda.bustamante.1417@hotmail.com', 46);
  INSERT INTO PERSONA VALUES (1418, 'Gustavo', 'Cardenas', 'Apaza', TO_DATE('1992-01-31', 'YYYY-MM-DD'), '5101418', '71011418', 'gustavo.cardenas.1418@gmail.com', 34);
  INSERT INTO PERSONA VALUES (1419, 'Erika', 'Maclean', 'Copana', TO_DATE('1987-05-15', 'YYYY-MM-DD'), '5101419', '71011419', 'erika.maclean.1419@yahoo.com', 38);
  INSERT INTO PERSONA VALUES (1420, 'Ricardo', 'Roca', 'Machaca', TO_DATE('2001-08-28', 'YYYY-MM-DD'), '5101420', '71011420', 'ricardo.roca.1420@gmail.com', 24);
  INSERT INTO PERSONA VALUES (1421, 'Pamela', 'Villarroel', 'Yujra', TO_DATE('1980-12-11', 'YYYY-MM-DD'), '5101421', '71011421', 'pamela.villarroel.1421@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1422, 'Victor', 'Aguilera', 'Pinto', TO_DATE('1994-03-25', 'YYYY-MM-DD'), '5101422', '71011422', 'victor.aguilera.1422@hotmail.com', 32);
  INSERT INTO PERSONA VALUES (1423, 'Cinthia', 'Soria', 'Nina', TO_DATE('1977-07-08', 'YYYY-MM-DD'), '5101423', '71011423', 'cinthia.soria.1423@gmail.com', 48);
  INSERT INTO PERSONA VALUES (1424, 'Rolando', 'Balderrama', 'Colque', TO_DATE('1990-10-21', 'YYYY-MM-DD'), '5101424', '71011424', 'rolando.balderrama.1424@yahoo.com', 35);
  INSERT INTO PERSONA VALUES (1425, 'Shirley', 'Guevara', 'Tarqui', TO_DATE('1985-02-03', 'YYYY-MM-DD'), '5101425', '71011425', 'shirley.guevara.1425@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1426, 'Nelson', 'Alba', 'Aliaga', TO_DATE('1998-05-18', 'YYYY-MM-DD'), '5101426', '71011426', 'nelson.alba.1426@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1427, 'Ruth', 'Cordero', 'Huanca', TO_DATE('1981-08-31', 'YYYY-MM-DD'), '5101427', '71011427', 'ruth.cordero.1427@hotmail.com', 44);
  INSERT INTO PERSONA VALUES (1428, 'Julio', 'Becerra', 'Ticona', TO_DATE('1995-12-14', 'YYYY-MM-DD'), '5101428', '71011428', 'julio.becerra.1428@gmail.com', 30);
  INSERT INTO PERSONA VALUES (1429, 'Beatriz', 'Salinas', 'Arias', TO_DATE('1976-03-28', 'YYYY-MM-DD'), '5101429', '71011429', 'beatriz.salinas.1429@yahoo.com', 50);
  INSERT INTO PERSONA VALUES (1430, 'Armando', 'Diaz', 'Poma', TO_DATE('1991-07-11', 'YYYY-MM-DD'), '5101430', '71011430', 'armando.diaz.1430@gmail.com', 34);
  INSERT INTO PERSONA VALUES (1431, 'Gladys', 'Romero', 'Cruz', TO_DATE('1988-10-24', 'YYYY-MM-DD'), '5101431', '71011431', 'gladys.romero.1431@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1432, 'Edgar', 'Blanco', 'Lima', TO_DATE('2002-02-06', 'YYYY-MM-DD'), '5101432', '71011432', 'edgar.blanco.1432@hotmail.com', 24);
  INSERT INTO PERSONA VALUES (1433, 'Cecilia', 'Rivas', 'Aruquipa', TO_DATE('1983-05-21', 'YYYY-MM-DD'), '5101433', '71011433', 'cecilia.rivas.1433@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1434, 'Ivan', 'Paredes', 'Chura', TO_DATE('1997-09-03', 'YYYY-MM-DD'), '5101434', '71011434', 'ivan.paredes.1434@yahoo.com', 28);
  INSERT INTO PERSONA VALUES (1435, 'Jimena', 'Navarro', 'Villca', TO_DATE('1979-12-17', 'YYYY-MM-DD'), '5101435', '71011435', 'jimena.navarro.1435@gmail.com', 46);
  INSERT INTO PERSONA VALUES (1436, 'Ruben', 'Soto', 'Siles', TO_DATE('1993-03-31', 'YYYY-MM-DD'), '5101436', '71011436', 'ruben.soto.1436@gmail.com', 33);
  INSERT INTO PERSONA VALUES (1437, 'Sonia', 'Molina', 'Caceres', TO_DATE('1986-07-14', 'YYYY-MM-DD'), '5101437', '71011437', 'sonia.molina.1437@hotmail.com', 39);
  INSERT INTO PERSONA VALUES (1438, 'Eduardo', 'Campos', 'Orellana', TO_DATE('1999-10-27', 'YYYY-MM-DD'), '5101438', '71011438', 'eduardo.campos.1438@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1439, 'Marlene', 'Vega', 'Mamani', TO_DATE('1982-02-09', 'YYYY-MM-DD'), '5101439', '71011439', 'marlene.vega.1439@yahoo.com', 44);
  INSERT INTO PERSONA VALUES (1440, 'Marco', 'Guzman', 'Quispe', TO_DATE('1995-05-24', 'YYYY-MM-DD'), '5101440', '71011440', 'marco.guzman.1440@gmail.com', 30);
  INSERT INTO PERSONA VALUES (1441, 'Nelly', 'Peña', 'Choque', TO_DATE('1976-09-06', 'YYYY-MM-DD'), '5101441', '71011441', 'nelly.pena.1441@gmail.com', 49);
  INSERT INTO PERSONA VALUES (1442, 'Alvaro', 'Mora', 'Condori', TO_DATE('1990-12-20', 'YYYY-MM-DD'), '5101442', '71011442', 'alvaro.mora.1442@hotmail.com', 35);
  INSERT INTO PERSONA VALUES (1443, 'Tania', 'Rey', 'Rojas', TO_DATE('1988-04-03', 'YYYY-MM-DD'), '5101443', '71011443', 'tania.rey.1443@gmail.com', 38);
  INSERT INTO PERSONA VALUES (1444, 'Felix', 'Cruz', 'Flores', TO_DATE('2001-07-17', 'YYYY-MM-DD'), '5101444', '71011444', 'felix.cruz.1444@yahoo.com', 24);
  INSERT INTO PERSONA VALUES (1445, 'Irene', 'Luna', 'Vargas', TO_DATE('1984-10-30', 'YYYY-MM-DD'), '5101445', '71011445', 'irene.luna.1445@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1446, 'Guido', 'Cabrera', 'Gutierrez', TO_DATE('1997-02-12', 'YYYY-MM-DD'), '5101446', '71011446', 'guido.cabrera.1446@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1447, 'Nancy', 'Marquez', 'Mendoza', TO_DATE('1979-05-27', 'YYYY-MM-DD'), '5101447', '71011447', 'nancy.marquez.1447@hotmail.com', 46);
  INSERT INTO PERSONA VALUES (1448, 'Denis', 'Pino', 'Apaza', TO_DATE('1993-09-09', 'YYYY-MM-DD'), '5101448', '71011448', 'denis.pino.1448@gmail.com', 32);
  INSERT INTO PERSONA VALUES (1449, 'Rosario', 'Salazar', 'Copana', TO_DATE('1986-12-23', 'YYYY-MM-DD'), '5101449', '71011449', 'rosario.salazar.1449@yahoo.com', 39);
  INSERT INTO PERSONA VALUES (1450, 'Hugo', 'Vera', 'Machaca', TO_DATE('2000-04-06', 'YYYY-MM-DD'), '5101450', '71011450', 'hugo.vera.1450@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1451, 'Paola', 'Gallo', 'Yujra', TO_DATE('1982-07-20', 'YYYY-MM-DD'), '5101451', '71011451', 'paola.gallo.1451@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1452, 'Esteban', 'Molina', 'Pinto', TO_DATE('1995-10-31', 'YYYY-MM-DD'), '5101452', '71011452', 'esteban.molina.1452@hotmail.com', 30);
  INSERT INTO PERSONA VALUES (1453, 'Lidia', 'Cano', 'Nina', TO_DATE('1977-02-13', 'YYYY-MM-DD'), '5101453', '71011453', 'lidia.cano.1453@gmail.com', 49);
  INSERT INTO PERSONA VALUES (1454, 'Rene', 'Tapia', 'Colque', TO_DATE('1991-05-28', 'YYYY-MM-DD'), '5101454', '71011454', 'rene.tapia.1454@yahoo.com', 34);
  INSERT INTO PERSONA VALUES (1455, 'Norma', 'Mora', 'Tarqui', TO_DATE('1988-09-10', 'YYYY-MM-DD'), '5101455', '71011455', 'norma.mora.1455@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1456, 'Alex', 'Montoya', 'Aliaga', TO_DATE('2002-12-24', 'YYYY-MM-DD'), '5101456', '71011456', 'alex.montoya.1456@gmail.com', 23);
  INSERT INTO PERSONA VALUES (1457, 'Blanca', 'Serrano', 'Huanca', TO_DATE('1984-04-07', 'YYYY-MM-DD'), '5101457', '71011457', 'blanca.serrano.1457@hotmail.com', 42);
  INSERT INTO PERSONA VALUES (1458, 'Arturo', 'Coronel', 'Ticona', TO_DATE('1997-07-21', 'YYYY-MM-DD'), '5101458', '71011458', 'arturo.coronel.1458@gmail.com', 28);
  INSERT INTO PERSONA VALUES (1459, 'Marta', 'Crespo', 'Arias', TO_DATE('1980-10-04', 'YYYY-MM-DD'), '5101459', '71011459', 'marta.crespo.1459@yahoo.com', 45);
  INSERT INTO PERSONA VALUES (1460, 'Grover', 'Delgado', 'Poma', TO_DATE('1993-01-17', 'YYYY-MM-DD'), '5101460', '71011460', 'grover.delgado.1460@gmail.com', 33);
  INSERT INTO PERSONA VALUES (1461, 'Juana', 'Pinto', 'Cruz', TO_DATE('1986-05-02', 'YYYY-MM-DD'), '5101461', '71011461', 'juana.pinto.1461@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1462, 'Mario', 'Salinas', 'Lima', TO_DATE('2000-08-15', 'YYYY-MM-DD'), '5101462', '71011462', 'mario.salinas.1462@hotmail.com', 25);
  INSERT INTO PERSONA VALUES (1463, 'Alicia', 'Vallejos', 'Aruquipa', TO_DATE('1982-11-28', 'YYYY-MM-DD'), '5101463', '71011463', 'alicia.vallejos.1463@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1464, 'Edwin', 'Carrillo', 'Chura', TO_DATE('1996-03-12', 'YYYY-MM-DD'), '5101464', '71011464', 'edwin.carrillo.1464@yahoo.com', 30);
  INSERT INTO PERSONA VALUES (1465, 'Jenny', 'Velasco', 'Villca', TO_DATE('1978-06-25', 'YYYY-MM-DD'), '5101465', '71011465', 'jenny.velasco.1465@gmail.com', 47);
  INSERT INTO PERSONA VALUES (1466, 'Saul', 'Huarachi', 'Siles', TO_DATE('1991-10-08', 'YYYY-MM-DD'), '5101466', '71011466', 'saul.huarachi.1466@gmail.com', 34);
  INSERT INTO PERSONA VALUES (1467, 'Doris', 'Peña', 'Caceres', TO_DATE('1988-01-21', 'YYYY-MM-DD'), '5101467', '71011467', 'doris.pena.1467@hotmail.com', 38);
  INSERT INTO PERSONA VALUES (1468, 'Fabian', 'Zarate', 'Orellana', TO_DATE('2002-05-05', 'YYYY-MM-DD'), '5101468', '71011468', 'fabian.zarate.1468@gmail.com', 23);
  INSERT INTO PERSONA VALUES (1469, 'Julia', 'Chavez', 'Mamani', TO_DATE('1984-08-18', 'YYYY-MM-DD'), '5101469', '71011469', 'julia.chavez.1469@yahoo.com', 41);
  INSERT INTO PERSONA VALUES (1470, 'Elio', 'Montero', 'Quispe', TO_DATE('1997-11-30', 'YYYY-MM-DD'), '5101470', '71011470', 'elio.montero.1470@gmail.com', 28);
  INSERT INTO PERSONA VALUES (1471, 'Griselda', 'Lora', 'Choque', TO_DATE('1980-03-15', 'YYYY-MM-DD'), '5101471', '71011471', 'griselda.lora.1471@gmail.com', 46);
  INSERT INTO PERSONA VALUES (1472, 'Boris', 'Bustamante', 'Condori', TO_DATE('1994-06-28', 'YYYY-MM-DD'), '5101472', '71011472', 'boris.bustamante.1472@hotmail.com', 31);
  INSERT INTO PERSONA VALUES (1473, 'Monica', 'Cardenas', 'Rojas', TO_DATE('1986-10-11', 'YYYY-MM-DD'), '5101473', '71011473', 'monica.cardenas.1473@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1474, 'Gaston', 'Maclean', 'Flores', TO_DATE('2000-01-24', 'YYYY-MM-DD'), '5101474', '71011474', 'gaston.maclean.1474@yahoo.com', 26);
  INSERT INTO PERSONA VALUES (1475, 'Yolanda', 'Roca', 'Vargas', TO_DATE('1982-05-08', 'YYYY-MM-DD'), '5101475', '71011475', 'yolanda.roca.1475@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1476, 'Richard', 'Villarroel', 'Gutierrez', TO_DATE('1995-08-21', 'YYYY-MM-DD'), '5101476', '71011476', 'richard.villarroel.1476@gmail.com', 30);
  INSERT INTO PERSONA VALUES (1477, 'Fabiola', 'Aguilera', 'Mendoza', TO_DATE('1978-12-04', 'YYYY-MM-DD'), '5101477', '71011477', 'fabiola.aguilera.1477@hotmail.com', 47);
  INSERT INTO PERSONA VALUES (1478, 'Marcelo', 'Soria', 'Apaza', TO_DATE('1992-03-18', 'YYYY-MM-DD'), '5101478', '71011478', 'marcelo.soria.1478@gmail.com', 34);
  INSERT INTO PERSONA VALUES (1479, 'Carla', 'Balderrama', 'Copana', TO_DATE('1988-06-30', 'YYYY-MM-DD'), '5101479', '71011479', 'carla.balderrama.1479@yahoo.com', 37);
  INSERT INTO PERSONA VALUES (1480, 'Sergio', 'Guevara', 'Machaca', TO_DATE('2002-10-13', 'YYYY-MM-DD'), '5101480', '71011480', 'sergio.guevara.1480@gmail.com', 23);
  INSERT INTO PERSONA VALUES (1481, 'Lizeth', 'Alba', 'Yujra', TO_DATE('1984-01-26', 'YYYY-MM-DD'), '5101481', '71011481', 'lizeth.alba.1481@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1482, 'Erick', 'Cordero', 'Pinto', TO_DATE('1997-05-10', 'YYYY-MM-DD'), '5101482', '71011482', 'erick.cordero.1482@hotmail.com', 28);
  INSERT INTO PERSONA VALUES (1483, 'Vania', 'Becerra', 'Nina', TO_DATE('1980-08-23', 'YYYY-MM-DD'), '5101483', '71011483', 'vania.becerra.1483@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1484, 'Johnny', 'Salinas', 'Colque', TO_DATE('1994-12-06', 'YYYY-MM-DD'), '5101484', '71011484', 'johnny.salinas.1484@yahoo.com', 31);
  INSERT INTO PERSONA VALUES (1485, 'Dayana', 'Diaz', 'Tarqui', TO_DATE('1986-03-20', 'YYYY-MM-DD'), '5101485', '71011485', 'dayana.diaz.1485@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1486, 'Wilson', 'Romero', 'Aliaga', TO_DATE('1999-07-03', 'YYYY-MM-DD'), '5101486', '71011486', 'wilson.romero.1486@hotmail.com', 26);
  INSERT INTO PERSONA VALUES (1487, 'Noelia', 'Blanco', 'Huanca', TO_DATE('1982-10-16', 'YYYY-MM-DD'), '5101487', '71011487', 'noelia.blanco.1487@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1488, 'Ramiro', 'Rivas', 'Ticona', TO_DATE('1995-01-29', 'YYYY-MM-DD'), '5101488', '71011488', 'ramiro.rivas.1488@yahoo.com', 31);
  INSERT INTO PERSONA VALUES (1489, 'Estela', 'Paredes', 'Arias', TO_DATE('1988-05-13', 'YYYY-MM-DD'), '5101489', '71011489', 'estela.paredes.1489@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1490, 'Omar', 'Navarro', 'Poma', TO_DATE('2002-08-26', 'YYYY-MM-DD'), '5101490', '71011490', 'omar.navarro.1490@hotmail.com', 23);
  INSERT INTO PERSONA VALUES (1491, 'Elva', 'Soto', 'Cruz', TO_DATE('1984-12-09', 'YYYY-MM-DD'), '5101491', '71011491', 'elva.soto.1491@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1492, 'Milton', 'Molina', 'Lima', TO_DATE('1997-03-24', 'YYYY-MM-DD'), '5101492', '71011492', 'milton.molina.1492@yahoo.com', 29);
  INSERT INTO PERSONA VALUES (1493, 'Lourdes', 'Campos', 'Aruquipa', TO_DATE('1980-07-07', 'YYYY-MM-DD'), '5101493', '71011493', 'lourdes.campos.1493@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1494, 'Ariel', 'Vega', 'Chura', TO_DATE('1993-10-20', 'YYYY-MM-DD'), '5101494', '71011494', 'ariel.vega.1494@hotmail.com', 32);
  INSERT INTO PERSONA VALUES (1495, 'Marcela', 'Guzman', 'Villca', TO_DATE('1986-01-02', 'YYYY-MM-DD'), '5101495', '71011495', 'marcela.guzman.1495@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1496, 'Cristian', 'Peña', 'Siles', TO_DATE('1999-04-16', 'YYYY-MM-DD'), '5101496', '71011496', 'cristian.pena.1496@yahoo.com', 27);
  INSERT INTO PERSONA VALUES (1497, 'Ester', 'Mora', 'Caceres', TO_DATE('1982-07-30', 'YYYY-MM-DD'), '5101497', '71011497', 'ester.mora.1497@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1498, 'Franklin', 'Rey', 'Orellana', TO_DATE('1995-11-12', 'YYYY-MM-DD'), '5101498', '71011498', 'franklin.rey.1498@hotmail.com', 30);
  INSERT INTO PERSONA VALUES (1499, 'Raquel', 'Cruz', 'Mamani', TO_DATE('1988-02-25', 'YYYY-MM-DD'), '5101499', '71011499', 'raquel.cruz.1499@gmail.com', 38);
  INSERT INTO PERSONA VALUES (1500, 'Ximena', 'Luna', 'Quispe', TO_DATE('2001-06-09', 'YYYY-MM-DD'), '5101500', '71011500', 'ximena.luna.1500@yahoo.com', 24);
  COMMIT;
END;
 




BEGIN
  INSERT INTO PERSONA VALUES (1501, 'Kevin', 'Cabrera', 'Condori', TO_DATE('1984-09-22', 'YYYY-MM-DD'), '5101501', '71011501', 'kevin.cabrera.1501@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1502, 'Evelyn', 'Marquez', 'Rojas', TO_DATE('1997-12-05', 'YYYY-MM-DD'), '5101502', '71011502', 'evelyn.marquez.1502@hotmail.com', 28);
  INSERT INTO PERSONA VALUES (1503, 'Jessica', 'Pino', 'Flores', TO_DATE('1980-03-19', 'YYYY-MM-DD'), '5101503', '71011503', 'jessica.pino.1503@gmail.com', 46);
  INSERT INTO PERSONA VALUES (1504, 'Christian', 'Salazar', 'Vargas', TO_DATE('1993-07-02', 'YYYY-MM-DD'), '5101504', '71011504', 'christian.salazar.1504@yahoo.com', 32);
  INSERT INTO PERSONA VALUES (1505, 'Diana', 'Vera', 'Mendoza', TO_DATE('1986-10-15', 'YYYY-MM-DD'), '5101505', '71011505', 'diana.vera.1505@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1506, 'Oscar', 'Gallo', 'Gutierrez', TO_DATE('1999-01-28', 'YYYY-MM-DD'), '5101506', '71011506', 'oscar.gallo.1506@hotmail.com', 27);
  INSERT INTO PERSONA VALUES (1507, 'Silvia', 'Molina', 'Apaza', TO_DATE('1982-05-13', 'YYYY-MM-DD'), '5101507', '71011507', 'silvia.molina.1507@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1508, 'Marcelo', 'Cano', 'Copana', TO_DATE('1995-08-26', 'YYYY-MM-DD'), '5101508', '71011508', 'marcelo.cano.1508@yahoo.com', 30);
  INSERT INTO PERSONA VALUES (1509, 'Karen', 'Tapia', 'Machaca', TO_DATE('1988-12-09', 'YYYY-MM-DD'), '5101509', '71011509', 'karen.tapia.1509@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1510, 'Pablo', 'Mora', 'Yujra', TO_DATE('2001-03-24', 'YYYY-MM-DD'), '5101510', '71011510', 'pablo.mora.1510@hotmail.com', 25);
  INSERT INTO PERSONA VALUES (1511, 'Wendy', 'Montoya', 'Pinto', TO_DATE('1984-07-07', 'YYYY-MM-DD'), '5101511', '71011511', 'wendy.montoya.1511@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1512, 'Javier', 'Serrano', 'Nina', TO_DATE('1997-10-20', 'YYYY-MM-DD'), '5101512', '71011512', 'javier.serrano.1512@yahoo.com', 28);
  INSERT INTO PERSONA VALUES (1513, 'Nadia', 'Coronel', 'Colque', TO_DATE('1980-01-02', 'YYYY-MM-DD'), '5101513', '71011513', 'nadia.coronel.1513@gmail.com', 46);
  INSERT INTO PERSONA VALUES (1514, 'Mauricio', 'Crespo', 'Tarqui', TO_DATE('1993-04-17', 'YYYY-MM-DD'), '5101514', '71011514', 'mauricio.crespo.1514@hotmail.com', 33);
  INSERT INTO PERSONA VALUES (1515, 'Brenda', 'Delgado', 'Aliaga', TO_DATE('1986-07-31', 'YYYY-MM-DD'), '5101515', '71011515', 'brenda.delgado.1515@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1516, 'Gustavo', 'Pinto', 'Huanca', TO_DATE('1999-11-13', 'YYYY-MM-DD'), '5101516', '71011516', 'gustavo.pinto.1516@yahoo.com', 26);
  INSERT INTO PERSONA VALUES (1517, 'Erika', 'Salinas', 'Ticona', TO_DATE('1982-02-26', 'YYYY-MM-DD'), '5101517', '71011517', 'erika.salinas.1517@gmail.com', 44);
  INSERT INTO PERSONA VALUES (1518, 'Ricardo', 'Vallejos', 'Arias', TO_DATE('1995-06-10', 'YYYY-MM-DD'), '5101518', '71011518', 'ricardo.vallejos.1518@hotmail.com', 30);
  INSERT INTO PERSONA VALUES (1519, 'Pamela', 'Carrillo', 'Poma', TO_DATE('1988-09-23', 'YYYY-MM-DD'), '5101519', '71011519', 'pamela.carrillo.1519@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1520, 'Victor', 'Velasco', 'Cruz', TO_DATE('2001-12-06', 'YYYY-MM-DD'), '5101520', '71011520', 'victor.velasco.1520@yahoo.com', 24);
  INSERT INTO PERSONA VALUES (1521, 'Cinthia', 'Huarachi', 'Lima', TO_DATE('1984-03-21', 'YYYY-MM-DD'), '5101521', '71011521', 'cinthia.huarachi.1521@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1522, 'Rolando', 'Peña', 'Aruquipa', TO_DATE('1997-07-04', 'YYYY-MM-DD'), '5101522', '71011522', 'rolando.pena.1522@hotmail.com', 28);
  INSERT INTO PERSONA VALUES (1523, 'Shirley', 'Zarate', 'Chura', TO_DATE('1980-10-17', 'YYYY-MM-DD'), '5101523', '71011523', 'shirley.zarate.1523@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1524, 'Nelson', 'Chavez', 'Caceres', TO_DATE('1993-01-30', 'YYYY-MM-DD'), '5101524', '71011524', 'nelson.chavez.1524@yahoo.com', 33);
  INSERT INTO PERSONA VALUES (1525, 'Ruth', 'Montero', 'Orellana', TO_DATE('1986-05-14', 'YYYY-MM-DD'), '5101525', '71011525', 'ruth.montero.1525@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1526, 'Julio', 'Lora', 'Rios', TO_DATE('1999-08-27', 'YYYY-MM-DD'), '5101526', '71011526', 'julio.lora.1526@hotmail.com', 26);
  INSERT INTO PERSONA VALUES (1527, 'Beatriz', 'Bustamante', 'Aguilar', TO_DATE('1982-12-10', 'YYYY-MM-DD'), '5101527', '71011527', 'beatriz.bustamante.1527@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1528, 'Armando', 'Cardenas', 'Salazar', TO_DATE('1995-03-25', 'YYYY-MM-DD'), '5101528', '71011528', 'armando.cardenas.1528@yahoo.com', 31);
  INSERT INTO PERSONA VALUES (1529, 'Gladys', 'Maclean', 'Miranda', TO_DATE('1988-07-08', 'YYYY-MM-DD'), '5101529', '71011529', 'gladys.maclean.1529@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1530, 'Edgar', 'Roca', 'Arce', TO_DATE('2001-10-21', 'YYYY-MM-DD'), '5101530', '71011530', 'edgar.roca.1530@hotmail.com', 24);
  INSERT INTO PERSONA VALUES (1531, 'Cecilia', 'Villarroel', 'Pacheco', TO_DATE('1984-01-03', 'YYYY-MM-DD'), '5101531', '71011531', 'cecilia.villarroel.1531@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1532, 'Ivan', 'Aguilera', 'Vera', TO_DATE('1997-04-18', 'YYYY-MM-DD'), '5101532', '71011532', 'ivan.aguilera.1532@yahoo.com', 29);
  INSERT INTO PERSONA VALUES (1533, 'Jimena', 'Soria', 'Encinas', TO_DATE('1980-07-31', 'YYYY-MM-DD'), '5101533', '71011533', 'jimena.soria.1533@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1534, 'Ruben', 'Balderrama', 'Escobar', TO_DATE('1993-11-13', 'YYYY-MM-DD'), '5101534', '71011534', 'ruben.balderrama.1534@hotmail.com', 32);
  INSERT INTO PERSONA VALUES (1535, 'Sonia', 'Guevara', 'Camacho', TO_DATE('1986-02-26', 'YYYY-MM-DD'), '5101535', '71011535', 'sonia.guevara.1535@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1536, 'Eduardo', 'Alba', 'Sosa', TO_DATE('1999-06-10', 'YYYY-MM-DD'), '5101536', '71011536', 'eduardo.alba.1536@yahoo.com', 26);
  INSERT INTO PERSONA VALUES (1537, 'Marlene', 'Cordero', 'Lazo', TO_DATE('1982-09-23', 'YYYY-MM-DD'), '5101537', '71011537', 'marlene.cordero.1537@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1538, 'Marco', 'Becerra', 'Cano', TO_DATE('1995-01-06', 'YYYY-MM-DD'), '5101538', '71011538', 'marco.becerra.1538@hotmail.com', 31);
  INSERT INTO PERSONA VALUES (1539, 'Nelly', 'Salinas', 'Tapia', TO_DATE('1988-04-20', 'YYYY-MM-DD'), '5101539', '71011539', 'nelly.salinas.1539@gmail.com', 38);
  INSERT INTO PERSONA VALUES (1540, 'Alvaro', 'Diaz', 'Mora', TO_DATE('2001-08-03', 'YYYY-MM-DD'), '5101540', '71011540', 'alvaro.diaz.1540@yahoo.com', 24);
  INSERT INTO PERSONA VALUES (1541, 'Tania', 'Romero', 'Montoya', TO_DATE('1984-11-16', 'YYYY-MM-DD'), '5101541', '71011541', 'tania.romero.1541@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1542, 'Felix', 'Blanco', 'Serrano', TO_DATE('1997-03-01', 'YYYY-MM-DD'), '5101542', '71011542', 'felix.blanco.1542@hotmail.com', 29);
  INSERT INTO PERSONA VALUES (1543, 'Irene', 'Rivas', 'Coronel', TO_DATE('1980-06-14', 'YYYY-MM-DD'), '5101543', '71011543', 'irene.rivas.1543@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1544, 'Guido', 'Paredes', 'Crespo', TO_DATE('1993-09-27', 'YYYY-MM-DD'), '5101544', '71011544', 'guido.paredes.1544@yahoo.com', 32);
  INSERT INTO PERSONA VALUES (1545, 'Nancy', 'Navarro', 'Delgado', TO_DATE('1986-01-10', 'YYYY-MM-DD'), '5101545', '71011545', 'nancy.navarro.1545@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1546, 'Denis', 'Soto', 'Salinas', TO_DATE('1999-04-24', 'YYYY-MM-DD'), '5101546', '71011546', 'denis.soto.1546@hotmail.com', 27);
  INSERT INTO PERSONA VALUES (1547, 'Rosario', 'Molina', 'Vallejos', TO_DATE('1982-08-07', 'YYYY-MM-DD'), '5101547', '71011547', 'rosario.molina.1547@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1548, 'Hugo', 'Campos', 'Carrillo', TO_DATE('1995-11-20', 'YYYY-MM-DD'), '5101548', '71011548', 'hugo.campos.1548@yahoo.com', 30);
  INSERT INTO PERSONA VALUES (1549, 'Paola', 'Vega', 'Velasco', TO_DATE('1988-03-05', 'YYYY-MM-DD'), '5101549', '71011549', 'paola.vega.1549@gmail.com', 38);
  INSERT INTO PERSONA VALUES (1550, 'Esteban', 'Guzman', 'Huarachi', TO_DATE('2001-06-18', 'YYYY-MM-DD'), '5101550', '71011550', 'esteban.guzman.1550@hotmail.com', 24);
  INSERT INTO PERSONA VALUES (1551, 'Lidia', 'Peña', 'Zarate', TO_DATE('1984-09-01', 'YYYY-MM-DD'), '5101551', '71011551', 'lidia.pena.1551@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1552, 'Rene', 'Mora', 'Chavez', TO_DATE('1997-12-14', 'YYYY-MM-DD'), '5101552', '71011552', 'rene.mora.1552@yahoo.com', 28);
  INSERT INTO PERSONA VALUES (1553, 'Norma', 'Rey', 'Montero', TO_DATE('1980-03-28', 'YYYY-MM-DD'), '5101553', '71011553', 'norma.rey.1553@gmail.com', 46);
  INSERT INTO PERSONA VALUES (1554, 'Alex', 'Cruz', 'Lora', TO_DATE('1993-07-11', 'YYYY-MM-DD'), '5101554', '71011554', 'alex.cruz.1554@hotmail.com', 32);
  INSERT INTO PERSONA VALUES (1555, 'Blanca', 'Luna', 'Bustamante', TO_DATE('1986-10-24', 'YYYY-MM-DD'), '5101555', '71011555', 'blanca.luna.1555@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1556, 'Arturo', 'Cabrera', 'Cardenas', TO_DATE('1999-02-06', 'YYYY-MM-DD'), '5101556', '71011556', 'arturo.cabrera.1556@yahoo.com', 27);
  INSERT INTO PERSONA VALUES (1557, 'Marta', 'Marquez', 'Maclean', TO_DATE('1982-05-21', 'YYYY-MM-DD'), '5101557', '71011557', 'marta.marquez.1557@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1558, 'Grover', 'Pino', 'Roca', TO_DATE('1995-09-03', 'YYYY-MM-DD'), '5101558', '71011558', 'grover.pino.1558@hotmail.com', 30);
  INSERT INTO PERSONA VALUES (1559, 'Juana', 'Salazar', 'Villarroel', TO_DATE('1988-12-16', 'YYYY-MM-DD'), '5101559', '71011559', 'juana.salazar.1559@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1560, 'Mario', 'Vera', 'Aguilera', TO_DATE('2001-03-31', 'YYYY-MM-DD'), '5101560', '71011560', 'mario.vera.1560@yahoo.com', 25);
  INSERT INTO PERSONA VALUES (1561, 'Alicia', 'Gallo', 'Soria', TO_DATE('1984-07-14', 'YYYY-MM-DD'), '5101561', '71011561', 'alicia.gallo.1561@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1562, 'Edwin', 'Molina', 'Balderrama', TO_DATE('1997-10-27', 'YYYY-MM-DD'), '5101562', '71011562', 'edwin.molina.1562@hotmail.com', 28);
  INSERT INTO PERSONA VALUES (1563, 'Jenny', 'Cano', 'Guevara', TO_DATE('1980-02-09', 'YYYY-MM-DD'), '5101563', '71011563', 'jenny.cano.1563@gmail.com', 46);
  INSERT INTO PERSONA VALUES (1564, 'Saul', 'Tapia', 'Alba', TO_DATE('1993-05-23', 'YYYY-MM-DD'), '5101564', '71011564', 'saul.tapia.1564@yahoo.com', 32);
  INSERT INTO PERSONA VALUES (1565, 'Doris', 'Mora', 'Cordero', TO_DATE('1986-09-05', 'YYYY-MM-DD'), '5101565', '71011565', 'doris.mora.1565@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1566, 'Fabian', 'Montoya', 'Becerra', TO_DATE('1999-12-18', 'YYYY-MM-DD'), '5101566', '71011566', 'fabian.montoya.1566@hotmail.com', 26);
  INSERT INTO PERSONA VALUES (1567, 'Julia', 'Serrano', 'Salinas', TO_DATE('1982-03-31', 'YYYY-MM-DD'), '5101567', '71011567', 'julia.serrano.1567@gmail.com', 44);
  INSERT INTO PERSONA VALUES (1568, 'Elio', 'Coronel', 'Diaz', TO_DATE('1995-07-14', 'YYYY-MM-DD'), '5101568', '71011568', 'elio.coronel.1568@yahoo.com', 30);
  INSERT INTO PERSONA VALUES (1569, 'Griselda', 'Crespo', 'Romero', TO_DATE('1988-10-27', 'YYYY-MM-DD'), '5101569', '71011569', 'griselda.crespo.1569@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1570, 'Boris', 'Delgado', 'Blanco', TO_DATE('2001-02-09', 'YYYY-MM-DD'), '5101570', '71011570', 'boris.delgado.1570@hotmail.com', 25);
  INSERT INTO PERSONA VALUES (1571, 'Monica', 'Pinto', 'Rivas', TO_DATE('1984-05-23', 'YYYY-MM-DD'), '5101571', '71011571', 'monica.pinto.1571@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1572, 'Gaston', 'Salinas', 'Paredes', TO_DATE('1997-09-05', 'YYYY-MM-DD'), '5101572', '71011572', 'gaston.salinas.1572@yahoo.com', 28);
  INSERT INTO PERSONA VALUES (1573, 'Yolanda', 'Vallejos', 'Navarro', TO_DATE('1980-12-18', 'YYYY-MM-DD'), '5101573', '71011573', 'yolanda.vallejos.1573@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1574, 'Richard', 'Carrillo', 'Soto', TO_DATE('1993-03-31', 'YYYY-MM-DD'), '5101574', '71011574', 'richard.carrillo.1574@hotmail.com', 33);
  INSERT INTO PERSONA VALUES (1575, 'Fabiola', 'Velasco', 'Molina', TO_DATE('1986-07-14', 'YYYY-MM-DD'), '5101575', '71011575', 'fabiola.velasco.1575@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1576, 'Marcelo', 'Huarachi', 'Campos', TO_DATE('1999-10-27', 'YYYY-MM-DD'), '5101576', '71011576', 'marcelo.huarachi.1576@yahoo.com', 26);
  INSERT INTO PERSONA VALUES (1577, 'Carla', 'Peña', 'Vega', TO_DATE('1982-02-09', 'YYYY-MM-DD'), '5101577', '71011577', 'carla.pena.1577@gmail.com', 44);
  INSERT INTO PERSONA VALUES (1578, 'Sergio', 'Zarate', 'Guzman', TO_DATE('1995-05-24', 'YYYY-MM-DD'), '5101578', '71011578', 'sergio.zarate.1578@hotmail.com', 30);
  INSERT INTO PERSONA VALUES (1579, 'Lizeth', 'Chavez', 'Peña', TO_DATE('1988-09-06', 'YYYY-MM-DD'), '5101579', '71011579', 'lizeth.chavez.1579@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1580, 'Erick', 'Montero', 'Mora', TO_DATE('2001-12-20', 'YYYY-MM-DD'), '5101580', '71011580', 'erick.montero.1580@yahoo.com', 24);
  INSERT INTO PERSONA VALUES (1581, 'Vania', 'Lora', 'Rey', TO_DATE('1984-04-03', 'YYYY-MM-DD'), '5101581', '71011581', 'vania.lora.1581@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1582, 'Johnny', 'Bustamante', 'Cruz', TO_DATE('1997-07-17', 'YYYY-MM-DD'), '5101582', '71011582', 'johnny.bustamante.1582@hotmail.com', 28);
  INSERT INTO PERSONA VALUES (1583, 'Dayana', 'Cardenas', 'Luna', TO_DATE('1980-10-30', 'YYYY-MM-DD'), '5101583', '71011583', 'dayana.cardenas.1583@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1584, 'Wilson', 'Maclean', 'Cabrera', TO_DATE('1993-02-12', 'YYYY-MM-DD'), '5101584', '71011584', 'wilson.maclean.1584@yahoo.com', 33);
  INSERT INTO PERSONA VALUES (1585, 'Noelia', 'Roca', 'Marquez', TO_DATE('1986-05-27', 'YYYY-MM-DD'), '5101585', '71011585', 'noelia.roca.1585@gmail.com', 39);
  INSERT INTO PERSONA VALUES (1586, 'Ramiro', 'Villarroel', 'Pino', TO_DATE('1999-09-09', 'YYYY-MM-DD'), '5101586', '71011586', 'ramiro.villarroel.1586@hotmail.com', 26);
  INSERT INTO PERSONA VALUES (1587, 'Estela', 'Aguilera', 'Salazar', TO_DATE('1982-12-23', 'YYYY-MM-DD'), '5101587', '71011587', 'estela.aguilera.1587@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1588, 'Omar', 'Soria', 'Vera', TO_DATE('1995-04-06', 'YYYY-MM-DD'), '5101588', '71011588', 'omar.soria.1588@yahoo.com', 31);
  INSERT INTO PERSONA VALUES (1589, 'Elva', 'Balderrama', 'Gallo', TO_DATE('1988-07-20', 'YYYY-MM-DD'), '5101589', '71011589', 'elva.balderrama.1589@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1590, 'Milton', 'Guevara', 'Molina', TO_DATE('2001-10-03', 'YYYY-MM-DD'), '5101590', '71011590', 'milton.guevara.1590@hotmail.com', 24);
  INSERT INTO PERSONA VALUES (1591, 'Lourdes', 'Alba', 'Cano', TO_DATE('1984-01-16', 'YYYY-MM-DD'), '5101591', '71011591', 'lourdes.alba.1591@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1592, 'Ariel', 'Cordero', 'Tapia', TO_DATE('1997-04-29', 'YYYY-MM-DD'), '5101592', '71011592', 'ariel.cordero.1592@yahoo.com', 28);
  INSERT INTO PERSONA VALUES (1593, 'Marcela', 'Becerra', 'Mora', TO_DATE('1980-08-12', 'YYYY-MM-DD'), '5101593', '71011593', 'marcela.becerra.1593@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1594, 'Cristian', 'Salinas', 'Montoya', TO_DATE('1993-11-25', 'YYYY-MM-DD'), '5101594', '71011594', 'cristian.salinas.1594@hotmail.com', 32);
  INSERT INTO PERSONA VALUES (1595, 'Ester', 'Diaz', 'Serrano', TO_DATE('1986-03-09', 'YYYY-MM-DD'), '5101595', '71011595', 'ester.diaz.1595@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1596, 'Franklin', 'Romero', 'Coronel', TO_DATE('1999-06-22', 'YYYY-MM-DD'), '5101596', '71011596', 'franklin.romero.1596@yahoo.com', 26);
  INSERT INTO PERSONA VALUES (1597, 'Raquel', 'Blanco', 'Crespo', TO_DATE('1982-10-05', 'YYYY-MM-DD'), '5101597', '71011597', 'raquel.blanco.1597@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1598, 'Ximena', 'Rivas', 'Delgado', TO_DATE('1995-01-18', 'YYYY-MM-DD'), '5101598', '71011598', 'ximena.rivas.1598@hotmail.com', 31);
  INSERT INTO PERSONA VALUES (1599, 'Kevin', 'Paredes', 'Pinto', TO_DATE('1988-05-02', 'YYYY-MM-DD'), '5101599', '71011599', 'kevin.paredes.1599@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1600, 'Evelyn', 'Navarro', 'Salinas', TO_DATE('2001-08-15', 'YYYY-MM-DD'), '5101600', '71011600', 'evelyn.navarro.1600@yahoo.com', 24);
  COMMIT;
END;



BEGIN
  INSERT INTO PERSONA VALUES (1601, 'Santiago', 'Zarate', 'Machaca', TO_DATE('1991-03-12', 'YYYY-MM-DD'), '5101601', '71011601', 'santiago.zarate.1601@gmail.com', 35);
  INSERT INTO PERSONA VALUES (1602, 'Valeria', 'Apaza', 'Yujra', TO_DATE('1984-11-05', 'YYYY-MM-DD'), '5101602', '71011602', 'valeria.apaza.1602@hotmail.com', 41);
  INSERT INTO PERSONA VALUES (1603, 'Matias', 'Colque', 'Nina', TO_DATE('1998-07-19', 'YYYY-MM-DD'), '5101603', '71011603', 'matias.colque.1603@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1604, 'Luciana', 'Tarqui', 'Colque', TO_DATE('1989-09-28', 'YYYY-MM-DD'), '5101604', '71011604', 'luciana.tarqui.1604@yahoo.com', 36);
  INSERT INTO PERSONA VALUES (1605, 'Leonardo', 'Aliaga', 'Tarqui', TO_DATE('2003-12-14', 'YYYY-MM-DD'), '5101605', '71011605', 'leo.aliaga.1605@gmail.com', 22);
  INSERT INTO PERSONA VALUES (1606, 'Mariana', 'Huanca', 'Aliaga', TO_DATE('1978-04-22', 'YYYY-MM-DD'), '5101606', '71011606', 'mariana.huanca.1606@hotmail.com', 48);
  INSERT INTO PERSONA VALUES (1607, 'Emiliano', 'Ticona', 'Huanca', TO_DATE('1994-08-08', 'YYYY-MM-DD'), '5101607', '71011607', 'emiliano.ticona.1607@gmail.com', 31);
  INSERT INTO PERSONA VALUES (1608, 'Renata', 'Arias', 'Ticona', TO_DATE('1981-01-15', 'YYYY-MM-DD'), '5101608', '71011608', 'renata.arias.1608@yahoo.com', 45);
  INSERT INTO PERSONA VALUES (1609, 'Lucas', 'Poma', 'Arias', TO_DATE('1996-05-28', 'YYYY-MM-DD'), '5101609', '71011609', 'lucas.poma.1609@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1610, 'Antonella', 'Cruz', 'Poma', TO_DATE('1987-10-11', 'YYYY-MM-DD'), '5101610', '71011610', 'antonella.cruz.1610@hotmail.com', 38);
  INSERT INTO PERSONA VALUES (1611, 'Joaquin', 'Lima', 'Cruz', TO_DATE('2000-02-25', 'YYYY-MM-DD'), '5101611', '71011611', 'joaquin.lima.1611@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1612, 'Martina', 'Aruquipa', 'Lima', TO_DATE('1983-06-03', 'YYYY-MM-DD'), '5101612', '71011612', 'martina.aruquipa.1612@yahoo.com', 42);
  INSERT INTO PERSONA VALUES (1613, 'Tomas', 'Chura', 'Aruquipa', TO_DATE('1992-12-07', 'YYYY-MM-DD'), '5101613', '71011613', 'tomas.chura.1613@gmail.com', 33);
  INSERT INTO PERSONA VALUES (1614, 'Catalina', 'Caceres', 'Chura', TO_DATE('1979-03-18', 'YYYY-MM-DD'), '5101614', '71011614', 'catalina.caceres.1614@hotmail.com', 47);
  INSERT INTO PERSONA VALUES (1615, 'Samuel', 'Orellana', 'Caceres', TO_DATE('1998-11-28', 'YYYY-MM-DD'), '5101615', '71011615', 'samuel.orellana.1615@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1616, 'Isabella', 'Rios', 'Orellana', TO_DATE('1985-07-05', 'YYYY-MM-DD'), '5101616', '71011616', 'isabella.rios.1616@yahoo.com', 40);
  INSERT INTO PERSONA VALUES (1617, 'Nicolas', 'Aguilar', 'Rios', TO_DATE('2002-09-14', 'YYYY-MM-DD'), '5101617', '71011617', 'nicolas.aguilar.1617@gmail.com', 23);
  INSERT INTO PERSONA VALUES (1618, 'Mia', 'Salazar', 'Aguilar', TO_DATE('1980-01-21', 'YYYY-MM-DD'), '5101618', '71011618', 'mia.salazar.1618@hotmail.com', 46);
  INSERT INTO PERSONA VALUES (1619, 'Sebastian', 'Miranda', 'Salazar', TO_DATE('1995-05-10', 'YYYY-MM-DD'), '5101619', '71011619', 'sebastian.miranda.1619@gmail.com', 30);
  INSERT INTO PERSONA VALUES (1620, 'Zoe', 'Arce', 'Miranda', TO_DATE('1988-08-27', 'YYYY-MM-DD'), '5101620', '71011620', 'zoe.arce.1620@yahoo.com', 37);
  INSERT INTO PERSONA VALUES (1621, 'Martin', 'Pacheco', 'Arce', TO_DATE('1976-11-12', 'YYYY-MM-DD'), '5101621', '71011621', 'martin.pacheco.1621@gmail.com', 49);
  INSERT INTO PERSONA VALUES (1622, 'Emilia', 'Vera', 'Pacheco', TO_DATE('1999-02-08', 'YYYY-MM-DD'), '5101622', '71011622', 'emilia.vera.1622@hotmail.com', 27);
  INSERT INTO PERSONA VALUES (1623, 'Felipe', 'Encinas', 'Vera', TO_DATE('1983-06-16', 'YYYY-MM-DD'), '5101623', '71011623', 'felipe.encinas.1623@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1624, 'Josefina', 'Escobar', 'Encinas', TO_DATE('2000-10-25', 'YYYY-MM-DD'), '5101624', '71011624', 'josefina.escobar.1624@yahoo.com', 25);
  INSERT INTO PERSONA VALUES (1625, 'Gael', 'Camacho', 'Escobar', TO_DATE('1987-12-04', 'YYYY-MM-DD'), '5101625', '71011625', 'gael.camacho.1625@gmail.com', 38);
  INSERT INTO PERSONA VALUES (1626, 'Luna', 'Sosa', 'Camacho', TO_DATE('1975-04-11', 'YYYY-MM-DD'), '5101626', '71011626', 'luna.sosa.1626@hotmail.com', 51);
  INSERT INTO PERSONA VALUES (1627, 'Facundo', 'Lazo', 'Sosa', TO_DATE('1994-08-19', 'YYYY-MM-DD'), '5101627', '71011627', 'facundo.lazo.1627@gmail.com', 31);
  INSERT INTO PERSONA VALUES (1628, 'Almendra', 'Cano', 'Lazo', TO_DATE('1981-03-28', 'YYYY-MM-DD'), '5101628', '71011628', 'almendra.cano.1628@yahoo.com', 45);
  INSERT INTO PERSONA VALUES (1629, 'Bruno', 'Tapia', 'Cano', TO_DATE('1996-07-07', 'YYYY-MM-DD'), '5101629', '71011629', 'bruno.tapia.1629@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1630, 'Olivia', 'Mora', 'Tapia', TO_DATE('1986-11-15', 'YYYY-MM-DD'), '5101630', '71011630', 'olivia.mora.1630@hotmail.com', 39);
  INSERT INTO PERSONA VALUES (1631, 'Dante', 'Montoya', 'Mora', TO_DATE('2001-01-24', 'YYYY-MM-DD'), '5101631', '71011631', 'dante.montoya.1631@gmail.com', 25);
  INSERT INTO PERSONA VALUES (1632, 'Delfina', 'Serrano', 'Montoya', TO_DATE('1980-05-06', 'YYYY-MM-DD'), '5101632', '71011632', 'delfina.serrano.1632@yahoo.com', 45);
  INSERT INTO PERSONA VALUES (1633, 'Thiago', 'Coronel', 'Serrano', TO_DATE('1992-10-18', 'YYYY-MM-DD'), '5101633', '71011633', 'thiago.coronel.1633@gmail.com', 33);
  INSERT INTO PERSONA VALUES (1634, 'Emma', 'Crespo', 'Coronel', TO_DATE('1985-02-27', 'YYYY-MM-DD'), '5101634', '71011634', 'emma.crespo.1634@hotmail.com', 41);
  INSERT INTO PERSONA VALUES (1635, 'Bautista', 'Delgado', 'Crespo', TO_DATE('1998-06-05', 'YYYY-MM-DD'), '5101635', '71011635', 'bautista.delgado.1635@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1636, 'Julieta', 'Salinas', 'Delgado', TO_DATE('1978-09-14', 'YYYY-MM-DD'), '5101636', '71011636', 'julieta.salinas.1636@yahoo.com', 47);
  INSERT INTO PERSONA VALUES (1637, 'Ignacio', 'Vallejos', 'Salinas', TO_DATE('1990-01-22', 'YYYY-MM-DD'), '5101637', '71011637', 'ignacio.vallejos.1637@gmail.com', 36);
  INSERT INTO PERSONA VALUES (1638, 'Mila', 'Carrillo', 'Vallejos', TO_DATE('1987-08-01', 'YYYY-MM-DD'), '5101638', '71011638', 'mila.carrillo.1638@hotmail.com', 38);
  INSERT INTO PERSONA VALUES (1639, 'Simon', 'Velasco', 'Carrillo', TO_DATE('1999-12-09', 'YYYY-MM-DD'), '5101639', '71011639', 'simon.velasco.1639@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1640, 'Sara', 'Huarachi', 'Velasco', TO_DATE('1982-04-19', 'YYYY-MM-DD'), '5101640', '71011640', 'sara.huarachi.1640@yahoo.com', 44);
  INSERT INTO PERSONA VALUES (1641, 'Maximo', 'Peña', 'Huarachi', TO_DATE('1995-11-28', 'YYYY-MM-DD'), '5101641', '71011641', 'maximo.pena.1641@gmail.com', 30);
  INSERT INTO PERSONA VALUES (1642, 'Rocio', 'Zarate', 'Peña', TO_DATE('1976-03-09', 'YYYY-MM-DD'), '5101642', '71011642', 'rocio.zarate.1642@hotmail.com', 50);
  INSERT INTO PERSONA VALUES (1643, 'Pedro', 'Chavez', 'Zarate', TO_DATE('1989-07-17', 'YYYY-MM-DD'), '5101643', '71011643', 'pedro.chavez.1643@gmail.com', 36);
  INSERT INTO PERSONA VALUES (1644, 'Elena', 'Montero', 'Chavez', TO_DATE('2002-10-26', 'YYYY-MM-DD'), '5101644', '71011644', 'elena.montero.1644@yahoo.com', 23);
  INSERT INTO PERSONA VALUES (1645, 'Gaspar', 'Lora', 'Montero', TO_DATE('1981-02-03', 'YYYY-MM-DD'), '5101645', '71011645', 'gaspar.lora.1645@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1646, 'Alicia', 'Bustamante', 'Lora', TO_DATE('1993-06-13', 'YYYY-MM-DD'), '5101646', '71011646', 'alicia.bustamante.1646@hotmail.com', 32);
  INSERT INTO PERSONA VALUES (1647, 'Fausto', 'Cardenas', 'Bustamante', TO_DATE('1985-11-21', 'YYYY-MM-DD'), '5101647', '71011647', 'fausto.cardenas.1647@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1648, 'Lola', 'Maclean', 'Cardenas', TO_DATE('1997-03-02', 'YYYY-MM-DD'), '5101648', '71011648', 'lola.maclean.1648@yahoo.com', 29);
  INSERT INTO PERSONA VALUES (1649, 'Vicente', 'Roca', 'Maclean', TO_DATE('1979-07-10', 'YYYY-MM-DD'), '5101649', '71011649', 'vicente.roca.1649@gmail.com', 46);
  INSERT INTO PERSONA VALUES (1650, 'Malena', 'Villarroel', 'Roca', TO_DATE('1991-12-19', 'YYYY-MM-DD'), '5101650', '71011650', 'malena.villarroel.1650@hotmail.com', 34);
  INSERT INTO PERSONA VALUES (1651, 'Valentin', 'Aguilera', 'Villarroel', TO_DATE('2003-04-28', 'YYYY-MM-DD'), '5101651', '71011651', 'valentin.aguilera.1651@gmail.com', 22);
  INSERT INTO PERSONA VALUES (1652, 'Amparo', 'Soria', 'Aguilera', TO_DATE('1982-09-06', 'YYYY-MM-DD'), '5101652', '71011652', 'amparo.soria.1652@yahoo.com', 43);
  INSERT INTO PERSONA VALUES (1653, 'Santino', 'Balderrama', 'Soria', TO_DATE('1996-01-14', 'YYYY-MM-DD'), '5101653', '71011653', 'santino.balderrama.1653@gmail.com', 30);
  INSERT INTO PERSONA VALUES (1654, 'Ines', 'Guevara', 'Balderrama', TO_DATE('1978-05-25', 'YYYY-MM-DD'), '5101654', '71011654', 'ines.guevara.1654@hotmail.com', 47);
  INSERT INTO PERSONA VALUES (1655, 'Jeronimo', 'Alba', 'Guevara', TO_DATE('1989-10-02', 'YYYY-MM-DD'), '5101655', '71011655', 'jeronimo.alba.1655@gmail.com', 36);
  INSERT INTO PERSONA VALUES (1656, 'Maite', 'Cordero', 'Alba', TO_DATE('2001-02-10', 'YYYY-MM-DD'), '5101656', '71011656', 'maite.cordero.1656@yahoo.com', 25);
  INSERT INTO PERSONA VALUES (1657, 'Ezequiel', 'Becerra', 'Cordero', TO_DATE('1983-06-20', 'YYYY-MM-DD'), '5101657', '71011657', 'ezequiel.becerra.1657@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1658, 'Guillermina', 'Salinas', 'Becerra', TO_DATE('1994-11-28', 'YYYY-MM-DD'), '5101658', '71011658', 'guille.salinas.1658@hotmail.com', 31);
  INSERT INTO PERSONA VALUES (1659, 'Teo', 'Diaz', 'Salinas', TO_DATE('1976-04-08', 'YYYY-MM-DD'), '5101659', '71011659', 'teo.diaz.1659@gmail.com', 50);
  INSERT INTO PERSONA VALUES (1660, 'Paz', 'Romero', 'Diaz', TO_DATE('1987-08-16', 'YYYY-MM-DD'), '5101660', '71011660', 'paz.romero.1660@yahoo.com', 38);
  INSERT INTO PERSONA VALUES (1661, 'Rocco', 'Blanco', 'Romero', TO_DATE('1999-12-25', 'YYYY-MM-DD'), '5101661', '71011661', 'rocco.blanco.1661@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1662, 'Florencia', 'Rivas', 'Blanco', TO_DATE('1981-05-04', 'YYYY-MM-DD'), '5101662', '71011662', 'flor.rivas.1662@hotmail.com', 44);
  INSERT INTO PERSONA VALUES (1663, 'Ian', 'Paredes', 'Rivas', TO_DATE('1993-09-12', 'YYYY-MM-DD'), '5101663', '71011663', 'ian.paredes.1663@gmail.com', 32);
  INSERT INTO PERSONA VALUES (1664, 'Nina', 'Navarro', 'Paredes', TO_DATE('1978-02-21', 'YYYY-MM-DD'), '5101664', '71011664', 'nina.navarro.1664@yahoo.com', 48);
  INSERT INTO PERSONA VALUES (1665, 'Cruz', 'Soto', 'Navarro', TO_DATE('1990-06-28', 'YYYY-MM-DD'), '5101665', '71011665', 'cruz.soto.1665@gmail.com', 35);
  INSERT INTO PERSONA VALUES (1666, 'Margarita', 'Molina', 'Soto', TO_DATE('2002-11-08', 'YYYY-MM-DD'), '5101666', '71011666', 'marga.molina.1666@hotmail.com', 23);
  INSERT INTO PERSONA VALUES (1667, 'Lisandro', 'Campos', 'Molina', TO_DATE('1983-03-18', 'YYYY-MM-DD'), '5101667', '71011667', 'lisandro.campos.1667@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1668, 'Jazmin', 'Vega', 'Campos', TO_DATE('1995-08-26', 'YYYY-MM-DD'), '5101668', '71011668', 'jazmin.vega.1668@yahoo.com', 30);
  INSERT INTO PERSONA VALUES (1669, 'Ciro', 'Guzman', 'Vega', TO_DATE('1979-01-03', 'YYYY-MM-DD'), '5101669', '71011669', 'ciro.guzman.1669@gmail.com', 47);
  INSERT INTO PERSONA VALUES (1670, 'Luciana', 'Peña', 'Guzman', TO_DATE('1991-05-13', 'YYYY-MM-DD'), '5101670', '71011670', 'luciana.pena.1670@hotmail.com', 34);
  INSERT INTO PERSONA VALUES (1671, 'Bastian', 'Mora', 'Peña', TO_DATE('2003-10-21', 'YYYY-MM-DD'), '5101671', '71011671', 'bastian.mora.1671@gmail.com', 22);
  INSERT INTO PERSONA VALUES (1672, 'Isidora', 'Rey', 'Mora', TO_DATE('1985-02-28', 'YYYY-MM-DD'), '5101672', '71011672', 'isidora.rey.1672@yahoo.com', 41); -- ¡Fecha corregida!
  INSERT INTO PERSONA VALUES (1673, 'Roman', 'Cruz', 'Rey', TO_DATE('1996-07-09', 'YYYY-MM-DD'), '5101673', '71011673', 'roman.cruz.1673@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1674, 'Amelia', 'Luna', 'Cruz', TO_DATE('1977-11-17', 'YYYY-MM-DD'), '5101674', '71011674', 'amelia.luna.1674@hotmail.com', 48);
  INSERT INTO PERSONA VALUES (1675, 'Ariel', 'Cabrera', 'Luna', TO_DATE('1989-04-26', 'YYYY-MM-DD'), '5101675', '71011675', 'ariel.cabrera.1675@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1676, 'Antonella', 'Marquez', 'Cabrera', TO_DATE('2000-09-03', 'YYYY-MM-DD'), '5101676', '71011676', 'anto.marquez.1676@yahoo.com', 25);
  INSERT INTO PERSONA VALUES (1677, 'Ulises', 'Pino', 'Marquez', TO_DATE('1982-01-12', 'YYYY-MM-DD'), '5101677', '71011677', 'ulises.pino.1677@gmail.com', 44);
  INSERT INTO PERSONA VALUES (1678, 'Bianca', 'Salazar', 'Pino', TO_DATE('1994-06-21', 'YYYY-MM-DD'), '5101678', '71011678', 'bianca.salazar.1678@hotmail.com', 31);
  INSERT INTO PERSONA VALUES (1679, 'Leon', 'Vera', 'Salazar', TO_DATE('1975-10-28', 'YYYY-MM-DD'), '5101679', '71011679', 'leon.vera.1679@gmail.com', 50);
  INSERT INTO PERSONA VALUES (1680, 'Celia', 'Gallo', 'Vera', TO_DATE('1987-03-09', 'YYYY-MM-DD'), '5101680', '71011680', 'celia.gallo.1680@yahoo.com', 39);
  INSERT INTO PERSONA VALUES (1681, 'Alejo', 'Molina', 'Gallo', TO_DATE('1999-07-18', 'YYYY-MM-DD'), '5101681', '71011681', 'alejo.molina.1681@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1682, 'Florencia', 'Cano', 'Molina', TO_DATE('1980-12-26', 'YYYY-MM-DD'), '5101682', '71011682', 'florencia.cano.1682@hotmail.com', 45);
  INSERT INTO PERSONA VALUES (1683, 'Elias', 'Tapia', 'Cano', TO_DATE('1992-05-05', 'YYYY-MM-DD'), '5101683', '71011683', 'elias.tapia.1683@gmail.com', 33);
  INSERT INTO PERSONA VALUES (1684, 'Maite', 'Mora', 'Tapia', TO_DATE('1978-09-13', 'YYYY-MM-DD'), '5101684', '71011684', 'maite.mora.1684@yahoo.com', 47);
  INSERT INTO PERSONA VALUES (1685, 'Aaron', 'Montoya', 'Mora', TO_DATE('1989-02-22', 'YYYY-MM-DD'), '5101685', '71011685', 'aaron.montoya.1685@gmail.com', 37);
  INSERT INTO PERSONA VALUES (1686, 'Micaela', 'Serrano', 'Montoya', TO_DATE('2001-07-02', 'YYYY-MM-DD'), '5101686', '71011686', 'micaela.serrano.1686@hotmail.com', 24);
  INSERT INTO PERSONA VALUES (1687, 'Camilo', 'Coronel', 'Serrano', TO_DATE('1983-11-10', 'YYYY-MM-DD'), '5101687', '71011687', 'camilo.coronel.1687@gmail.com', 42);
  INSERT INTO PERSONA VALUES (1688, 'Celia', 'Crespo', 'Coronel', TO_DATE('1995-03-20', 'YYYY-MM-DD'), '5101688', '71011688', 'celia.crespo.1688@yahoo.com', 31);
  INSERT INTO PERSONA VALUES (1689, 'Noel', 'Delgado', 'Crespo', TO_DATE('1976-08-28', 'YYYY-MM-DD'), '5101689', '71011689', 'noel.delgado.1689@gmail.com', 49);
  INSERT INTO PERSONA VALUES (1690, 'Violeta', 'Salinas', 'Delgado', TO_DATE('1988-01-06', 'YYYY-MM-DD'), '5101690', '71011690', 'violeta.salinas.1690@hotmail.com', 38);
  INSERT INTO PERSONA VALUES (1691, 'Fidel', 'Vallejos', 'Salinas', TO_DATE('2000-05-15', 'YYYY-MM-DD'), '5101691', '71011691', 'fidel.vallejos.1691@gmail.com', 25);
  INSERT INTO PERSONA VALUES (1692, 'Abril', 'Carrillo', 'Vallejos', TO_DATE('1981-09-23', 'YYYY-MM-DD'), '5101692', '71011692', 'abril.carrillo.1692@yahoo.com', 44);
  INSERT INTO PERSONA VALUES (1693, 'Alex', 'Velasco', 'Carrillo', TO_DATE('1993-02-01', 'YYYY-MM-DD'), '5101693', '71011693', 'alex.velasco.1693@gmail.com', 33);
  INSERT INTO PERSONA VALUES (1694, 'Justina', 'Huarachi', 'Velasco', TO_DATE('1979-06-11', 'YYYY-MM-DD'), '5101694', '71011694', 'justina.huarachi.1694@hotmail.com', 46);
  INSERT INTO PERSONA VALUES (1695, 'Oliver', 'Peña', 'Huarachi', TO_DATE('1990-10-19', 'YYYY-MM-DD'), '5101695', '71011695', 'oliver.pena.1695@gmail.com', 35);
  INSERT INTO PERSONA VALUES (1696, 'Miranda', 'Zarate', 'Peña', TO_DATE('2002-03-28', 'YYYY-MM-DD'), '5101696', '71011696', 'miranda.zarate.1696@yahoo.com', 24);
  INSERT INTO PERSONA VALUES (1697, 'Enzo', 'Chavez', 'Zarate', TO_DATE('1984-08-07', 'YYYY-MM-DD'), '5101697', '71011697', 'enzo.chavez.1697@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1698, 'Macarena', 'Montero', 'Chavez', TO_DATE('1996-12-16', 'YYYY-MM-DD'), '5101698', '71011698', 'maca.montero.1698@hotmail.com', 29);
  INSERT INTO PERSONA VALUES (1699, 'Tobias', 'Lora', 'Montero', TO_DATE('1977-04-25', 'YYYY-MM-DD'), '5101699', '71011699', 'tobias.lora.1699@gmail.com', 49);
  INSERT INTO PERSONA VALUES (1700, 'Paulina', 'Bustamante', 'Lora', TO_DATE('1989-09-03', 'YYYY-MM-DD'), '5101700', '71011700', 'paulina.busta.1700@yahoo.com', 36);
  COMMIT;
END;
asd

BEGIN
  INSERT INTO PERSONA VALUES (1701, 'Martin', 'Cardenas', 'Maclean', TO_DATE('1981-01-12', 'YYYY-MM-DD'), '5101701', '71011701', 'martin.cardenas.1701@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1702, 'Emilia', 'Maclean', 'Roca', TO_DATE('1993-05-26', 'YYYY-MM-DD'), '5101702', '71011702', 'emilia.maclean.1702@hotmail.com', 33);
  INSERT INTO PERSONA VALUES (1703, 'Felipe', 'Roca', 'Aguilera', TO_DATE('1978-10-09', 'YYYY-MM-DD'), '5101703', '71011703', 'felipe.roca.1703@gmail.com', 47);
  INSERT INTO PERSONA VALUES (1704, 'Josefina', 'Aguilera', 'Soria', TO_DATE('1990-02-23', 'YYYY-MM-DD'), '5101704', '71011704', 'josefina.aguilera.1704@yahoo.com', 36);
  INSERT INTO PERSONA VALUES (1705, 'Gael', 'Soria', 'Balderrama', TO_DATE('2002-07-08', 'YYYY-MM-DD'), '5101705', '71011705', 'gael.soria.1705@gmail.com', 23);
  INSERT INTO PERSONA VALUES (1706, 'Luna', 'Balderrama', 'Guevara', TO_DATE('1985-11-21', 'YYYY-MM-DD'), '5101706', '71011706', 'luna.balderrama.1706@hotmail.com', 40);
  INSERT INTO PERSONA VALUES (1707, 'Facundo', 'Guevara', 'Alba', TO_DATE('1997-04-05', 'YYYY-MM-DD'), '5101707', '71011707', 'facundo.guevara.1707@gmail.com', 29);
  INSERT INTO PERSONA VALUES (1708, 'Almendra', 'Alba', 'Cordero', TO_DATE('1979-08-19', 'YYYY-MM-DD'), '5101708', '71011708', 'almendra.alba.1708@yahoo.com', 46);
  INSERT INTO PERSONA VALUES (1709, 'Bruno', 'Cordero', 'Becerra', TO_DATE('1991-12-02', 'YYYY-MM-DD'), '5101709', '71011709', 'bruno.cordero.1709@gmail.com', 34);
  INSERT INTO PERSONA VALUES (1710, 'Olivia', 'Becerra', 'Salinas', TO_DATE('2003-04-16', 'YYYY-MM-DD'), '5101710', '71011710', 'olivia.becerra.1710@hotmail.com', 23);
  INSERT INTO PERSONA VALUES (1711, 'Dante', 'Salinas', 'Diaz', TO_DATE('1982-09-28', 'YYYY-MM-DD'), '5101711', '71011711', 'dante.salinas.1711@gmail.com', 43);
  INSERT INTO PERSONA VALUES (1712, 'Delfina', 'Diaz', 'Romero', TO_DATE('1994-02-11', 'YYYY-MM-DD'), '5101712', '71011712', 'delfina.diaz.1712@yahoo.com', 32);
  INSERT INTO PERSONA VALUES (1713, 'Thiago', 'Romero', 'Blanco', TO_DATE('1976-06-25', 'YYYY-MM-DD'), '5101713', '71011713', 'thiago.romero.1713@gmail.com', 49);
  INSERT INTO PERSONA VALUES (1714, 'Emma', 'Blanco', 'Rivas', TO_DATE('1988-11-08', 'YYYY-MM-DD'), '5101714', '71011714', 'emma.blanco.1714@hotmail.com', 37);
  INSERT INTO PERSONA VALUES (1715, 'Bautista', 'Rivas', 'Paredes', TO_DATE('2000-03-22', 'YYYY-MM-DD'), '5101715', '71011715', 'bautista.rivas.1715@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1716, 'Julieta', 'Paredes', 'Navarro', TO_DATE('1983-08-04', 'YYYY-MM-DD'), '5101716', '71011716', 'julieta.paredes.1716@yahoo.com', 42);
  INSERT INTO PERSONA VALUES (1717, 'Ignacio', 'Navarro', 'Soto', TO_DATE('1995-12-18', 'YYYY-MM-DD'), '5101717', '71011717', 'ignacio.navarro.1717@gmail.com', 30);
  INSERT INTO PERSONA VALUES (1718, 'Mila', 'Soto', 'Molina', TO_DATE('1977-05-02', 'YYYY-MM-DD'), '5101718', '71011718', 'mila.soto.1718@hotmail.com', 48);
  INSERT INTO PERSONA VALUES (1719, 'Simon', 'Molina', 'Campos', TO_DATE('1989-09-15', 'YYYY-MM-DD'), '5101719', '71011719', 'simon.molina.1719@gmail.com', 36);
  INSERT INTO PERSONA VALUES (1720, 'Sara', 'Campos', 'Vega', TO_DATE('2001-01-28', 'YYYY-MM-DD'), '5101720', '71011720', 'sara.campos.1720@yahoo.com', 25);
  INSERT INTO PERSONA VALUES (1721, 'Maximo', 'Vega', 'Guzman', TO_DATE('1984-06-12', 'YYYY-MM-DD'), '5101721', '71011721', 'maximo.vega.1721@gmail.com', 41);
  INSERT INTO PERSONA VALUES (1722, 'Rocio', 'Guzman', 'Peña', TO_DATE('1996-10-25', 'YYYY-MM-DD'), '5101722', '71011722', 'rocio.guzman.1722@hotmail.com', 29);
  INSERT INTO PERSONA VALUES (1723, 'Pedro', 'Peña', 'Mora', TO_DATE('1978-03-09', 'YYYY-MM-DD'), '5101723', '71011723', 'pedro.pena.1723@gmail.com', 48);
  INSERT INTO PERSONA VALUES (1724, 'Elena', 'Mora', 'Rey', TO_DATE('1990-07-23', 'YYYY-MM-DD'), '5101724', '71011724', 'elena.mora.1724@yahoo.com', 35);
  INSERT INTO PERSONA VALUES (1725, 'Gaspar', 'Rey', 'Cruz', TO_DATE('2002-12-06', 'YYYY-MM-DD'), '5101725', '71011725', 'gaspar.rey.1725@gmail.com', 23);
  INSERT INTO PERSONA VALUES (1726, 'Alicia', 'Cruz', 'Luna', TO_DATE('1985-04-20', 'YYYY-MM-DD'), '5101726', '71011726', 'alicia.cruz.1726@hotmail.com', 41);
  INSERT INTO PERSONA VALUES (1727, 'Fausto', 'Luna', 'Cabrera', TO_DATE('1997-09-02', 'YYYY-MM-DD'), '5101727', '71011727', 'fausto.luna.1727@gmail.com', 28);
  INSERT INTO PERSONA VALUES (1728, 'Lola', 'Cabrera', 'Marquez', TO_DATE('1979-01-16', 'YYYY-MM-DD'), '5101728', '71011728', 'lola.cabrera.1728@yahoo.com', 47);
  INSERT INTO PERSONA VALUES (1729, 'Vicente', 'Marquez', 'Pino', TO_DATE('1991-05-30', 'YYYY-MM-DD'), '5101729', '71011729', 'vicente.marquez.1729@gmail.com', 34);
  INSERT INTO PERSONA VALUES (1730, 'Malena', 'Pino', 'Salazar', TO_DATE('2003-10-13', 'YYYY-MM-DD'), '5101730', '71011730', 'malena.pino.1730@hotmail.com', 22);
  INSERT INTO PERSONA VALUES (1731, 'Valentin', 'Salazar', 'Vera', TO_DATE('1986-02-26', 'YYYY-MM-DD'), '5101731', '71011731', 'valentin.salazar.1731@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1732, 'Amparo', 'Vera', 'Gallo', TO_DATE('1998-07-10', 'YYYY-MM-DD'), '5101732', '71011732', 'amparo.vera.1732@yahoo.com', 27);
  INSERT INTO PERSONA VALUES (1733, 'Santino', 'Gallo', 'Molina', TO_DATE('1980-11-23', 'YYYY-MM-DD'), '5101733', '71011733', 'santino.gallo.1733@gmail.com', 45);
  INSERT INTO PERSONA VALUES (1734, 'Ines', 'Molina', 'Cano', TO_DATE('1992-04-06', 'YYYY-MM-DD'), '5101734', '71011734', 'ines.molina.1734@hotmail.com', 34);
  INSERT INTO PERSONA VALUES (1735, 'Jeronimo', 'Cano', 'Tapia', TO_DATE('2004-08-19', 'YYYY-MM-DD'), '5101735', '71011735', 'jeronimo.cano.1735@gmail.com', 21);
  INSERT INTO PERSONA VALUES (1736, 'Maite', 'Tapia', 'Mora', TO_DATE('1987-01-02', 'YYYY-MM-DD'), '5101736', '71011736', 'maite.tapia.1736@yahoo.com', 39);
  INSERT INTO PERSONA VALUES (1737, 'Ezequiel', 'Mora', 'Montoya', TO_DATE('1999-05-16', 'YYYY-MM-DD'), '5101737', '71011737', 'ezequiel.mora.1737@gmail.com', 26);
  INSERT INTO PERSONA VALUES (1738, 'Guillermina', 'Montoya', 'Serrano', TO_DATE('1981-09-29', 'YYYY-MM-DD'), '5101738', '71011738', 'guille.montoya.1738@hotmail.com', 44);
  INSERT INTO PERSONA VALUES (1739, 'Teo', 'Serrano', 'Coronel', TO_DATE('1993-02-11', 'YYYY-MM-DD'), '5101739', '71011739', 'teo.serrano.1739@gmail.com', 33);
  INSERT INTO PERSONA VALUES (1740, 'Paz', 'Coronel', 'Crespo', TO_DATE('1978-06-25', 'YYYY-MM-DD'), '5101740', '71011740', 'paz.coronel.1740@yahoo.com', 47);
  INSERT INTO PERSONA VALUES (1741, 'Rocco', 'Crespo', 'Delgado', TO_DATE('1990-11-08', 'YYYY-MM-DD'), '5101741', '71011741', 'rocco.crespo.1741@gmail.com', 35);
  INSERT INTO PERSONA VALUES (1742, 'Florencia', 'Delgado', 'Salinas', TO_DATE('2002-03-22', 'YYYY-MM-DD'), '5101742', '71011742', 'flor.delgado.1742@hotmail.com', 24);
  INSERT INTO PERSONA VALUES (1743, 'Ian', 'Salinas', 'Vallejos', TO_DATE('1985-07-05', 'YYYY-MM-DD'), '5101743', '71011743', 'ian.salinas.1743@gmail.com', 40);
  INSERT INTO PERSONA VALUES (1744, 'Nina', 'Vallejos', 'Carrillo', TO_DATE('1997-11-18', 'YYYY-MM-DD'), '5101744', '71011744', 'nina.vallejos.1744@yahoo.com', 28);
  INSERT INTO PERSONA VALUES (1745, 'Cruz', 'Carrillo', 'Velasco', TO_DATE('1979-04-02', 'YYYY-MM-DD'), '5101745', '71011745', 'cruz.carrillo.1745@gmail.com', 47);
  INSERT INTO PERSONA VALUES (1746, 'Margarita', 'Velasco', 'Huarachi', TO_DATE('1991-08-15', 'YYYY-MM-DD'), '5101746', '71011746', 'marga.velasco.1746@hotmail.com', 34);
  INSERT INTO PERSONA VALUES (1747, 'Lisandro', 'Huarachi', 'Peña', TO_DATE('2003-12-28', 'YYYY-MM-DD'), '5101747', '71011747', 'lisandro.huarachi.1747@gmail.com', 22);
  INSERT INTO PERSONA VALUES (1748, 'Jazmin', 'Peña', 'Zarate', TO_DATE('1986-05-12', 'YYYY-MM-DD'), '5101748', '71011748', 'jazmin.pena.1748@yahoo.com', 39);
  INSERT INTO PERSONA VALUES (1749, 'Ciro', 'Zarate', 'Chavez', TO_DATE('1998-09-25', 'YYYY-MM-DD'), '5101749', '71011749', 'ciro.zarate.1749@gmail.com', 27);
  INSERT INTO PERSONA VALUES (1750, 'Luciana', 'Chavez', 'Montero', TO_DATE('1980-02-08', 'YYYY-MM-DD'), '5101750', '71011750', 'luciana.chavez.1750@hotmail.com', 46);
  COMMIT;
END;
 









--EMPRESA_DELIVERY 

BEGIN
  -- 1. Repartidores Independientes
  INSERT INTO EMPRESA_DELIVERY VALUES (3001, 'Repartidores Independientes', '000000', 'S N', 10.00, 2.00, 'Activo');
  
  -- Empresas Reales   Muy conocidas en Bolivia
  INSERT INTO EMPRESA_DELIVERY VALUES (3002, 'PedidosYa Bolivia', '1029384021', '2-2114455', 12.00, 2.10, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3003, 'Yaigo Delivery', '3948572019', '3-3456789', 14.00, 1.80, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3004, 'Uber Eats Bolivia', '9485761023', '2-2441010', 15.00, 2.50, 'Inactivo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3005, 'Rappi Bolivia', '5847362018', '71234567', 13.00, 2.40, 'Inactivo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3006, 'InDrive Delivery', '1928374650', '60123456', 10.00, 1.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3007, 'PatioService Express', '4857392011', '3-3334455', 18.00, 2.80, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3008, 'SuperTicket Logística', '5748392015', '2-2900900', 15.00, 2.00, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3009, 'Mr. Delivery Bolivia', '9384756012', '75098765', 12.50, 1.90, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3010, 'Dinky Delivery', '1029485736', '77011223', 11.00, 1.70, 'Activo');

  -- Ficticias con identidad local
  INSERT INTO EMPRESA_DELIVERY VALUES (3011, 'Chasqui Express', '4059687013', '2-2808080', 10.00, 1.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3012, 'Moto Méndez Logística', '2938475014', '4-6644332', 9.00, 1.40, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3013, 'Illimani Courier', '8475639015', '2-2445566', 13.00, 1.80, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3014, 'Cóndor Delivery', '5748392016', '3-3556677', 14.50, 2.20, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3015, 'Kantuta Logística', '3948571027', '2-2112233', 11.00, 1.60, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3016, 'Andes Express', '8374659018', '71556677', 12.00, 2.00, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3017, 'Valle Logística', '1928375019', '4-4223344', 10.50, 1.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3018, 'Oriente Delivery', '4857391020', '3-3445566', 15.00, 2.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3019, 'Salar Express', '5847361021', '76001122', 14.00, 2.10, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3020, 'Amazonía Courier', '2938476022', '3-8445566', 18.00, 3.00, 'Suspendido');
  INSERT INTO EMPRESA_DELIVERY VALUES (3021, 'Chaco Delivery', '1029385023', '77002233', 16.00, 2.70, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3022, 'Llama Logística', '3948573024', '2-2123456', 11.50, 1.70, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3023, 'Puma Express', '8475631025', '71098765', 13.50, 2.00, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3024, 'SumaQ Delivery', '5748394026', '68012345', 10.00, 1.40, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3025, 'Jukumari Express', '9384752027', '75055443', 12.00, 1.80, 'Inactivo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3026, 'Titicaca Courier', '1928376028', '2-2866554', 14.00, 2.20, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3027, 'Sajama Delivery', '4857393029', '77055667', 15.00, 2.40, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3028, 'Tunari Express', '5847364030', '4-4112233', 10.50, 1.60, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3029, 'Parapeti Logística', '2938477031', '3-3887766', 16.50, 2.50, 'Activo');

  -- Ficticias con nombres modernos   App style
  INSERT INTO EMPRESA_DELIVERY VALUES (3030, 'FastBolivia', '1029386032', '71223344', 12.00, 1.90, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3031, 'GoDelivery BO', '3948575033', '68112233', 11.00, 1.80, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3032, 'SendIt Bolivia', '8475632034', '75001122', 13.00, 2.10, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3033, 'Rapigo Express', '5748395035', '77009988', 14.50, 2.30, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3034, 'FlashBO Courier', '9384753036', '2-2443322', 10.00, 1.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3035, 'EnvioSeguro Bolivia', '1928377037', '3-3221100', 15.00, 2.00, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3036, 'Paquetes YA', '4857394038', '71554433', 11.50, 1.70, 'Suspendido');
  INSERT INTO EMPRESA_DELIVERY VALUES (3037, 'Click&Go Bolivia', '5847365039', '68007766', 12.50, 1.90, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3038, 'TuMandado BO', '2938478040', '75004455', 9.50, 1.30, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3039, 'Encomiendas Bolivia', '1029387041', '2-2115566', 14.00, 2.20, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3040, 'MotoClick', '3948576042', '77006655', 10.00, 1.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3041, 'Urbanos Logística', '8475633043', '3-3554433', 13.50, 2.00, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3042, 'BiciGo Delivery', '5748396044', '71008899', 8.00, 1.00, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3043, 'Delivery Pro Bolivia', '9384754045', '68119988', 16.00, 2.50, 'Inactivo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3044, 'NetCourier BO', '1928378046', '2-2901122', 12.00, 1.80, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3045, 'SupraDelivery', '4857395047', '75003322', 14.50, 2.30, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3046, 'OmniExpress', '5847366048', '77001144', 15.50, 2.40, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3047, 'Veloce Delivery', '2938479049', '3-3442211', 11.00, 1.60, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3048, 'EnvioClick', '1029388050', '71559900', 10.50, 1.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3049, 'NeoDelivery', '3948577051', '68002233', 13.00, 1.90, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3050, 'Altura Delivery', '8475634052', '2-2805566', 11.50, 1.80, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3051, 'MetaCourier', '5748397053', '75006677', 14.00, 2.10, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3052, 'Rápido y Seguro S.A.', '9384755054', '77005544', 12.50, 1.90, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3053, 'ExpressLine Bolivia', '1928379055', '3-3881122', 15.00, 2.20, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3054, 'Box Delivery BO', '4857396056', '71003344', 10.00, 1.40, 'Suspendido');
  INSERT INTO EMPRESA_DELIVERY VALUES (3055, 'ServiExpress', '5847367057', '68114455', 11.50, 1.70, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3056, 'Punto a Punto Delivery', '2938470058', '2-2448899', 13.50, 2.00, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3057, 'Altiplano Logística', '1029389059', '75008899', 14.50, 2.30, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3058, 'MotoVoy Bolivia', '3948578060', '77004411', 9.50, 1.30, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3059, 'LlevaTodo S.R.L.', '8475635061', '3-3551100', 12.00, 1.80, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3060, 'ChasquiTracker', '5748398062', '71552211', 15.00, 2.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3061, 'Andino Express', '9384756063', '68005544', 11.00, 1.60, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3062, 'Bolivian Courier', '1928370064', '2-2117788', 16.00, 2.60, 'Inactivo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3063, 'A Tu Puerta Bolivia', '4857397065', '75002233', 10.50, 1.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3064, 'Red Express BO', '5847368066', '77003366', 13.00, 2.00, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3065, 'EnviaFácil', '2938471067', '3-3448877', 12.50, 1.90, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3066, 'MotoRed Bolivia', '1029380068', '71005522', 9.00, 1.40, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3067, 'GoLogistics', '3948579069', '68117766', 14.50, 2.20, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3068, 'Delivery 365', '8475636070', '2-2804455', 11.50, 1.80, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3069, 'TuPaquete BO', '5748399071', '75007788', 13.50, 2.10, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3070, 'Correos Bolivia Express', '9384757072', '77008899', 15.50, 2.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3071, 'Mensajería VIP', '1928371073', '3-3229988', 20.00, 3.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3072, 'EcoDelivery Bolivia', '4857398074', '71556633', 9.50, 1.20, 'Suspendido');
  INSERT INTO EMPRESA_DELIVERY VALUES (3073, 'Flash Courier', '5847369075', '68004477', 12.00, 1.90, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3074, 'Turbo Envíos', '2938472076', '2-2903344', 14.00, 2.30, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3075, 'Zona Delivery BO', '1029381077', '75001199', 11.00, 1.70, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3076, 'Ruta Rápida Logística', '3948570078', '77002288', 13.00, 2.00, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3077, 'En Camino Express', '8475637079', '3-3559900', 10.50, 1.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3078, 'Movil Delivery', '5748390080', '71004466', 12.50, 1.80, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3079, 'Ciudad Express', '9384758081', '68115533', 15.00, 2.40, 'Inactivo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3080, 'Express 24 Horas', '1928372082', '2-2119988', 14.50, 2.20, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3081, 'Capital Courier', '4857399083', '75008811', 13.50, 2.10, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3082, 'Logística del Sur', '5847360084', '77009911', 16.00, 2.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3083, 'Logística del Norte', '2938473085', '3-3884455', 16.00, 2.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3084, 'Vía Rápida Delivery', '1029382086', '71557788', 11.50, 1.80, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3085, 'Mandaditos BO', '3948571087', '68009922', 10.00, 1.40, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3086, 'TuEncargo Express', '8475638088', '2-2801122', 12.00, 1.90, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3087, 'Siempre Listo Delivery', '5748391089', '75005511', 14.00, 2.20, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3088, 'MotoExpress S.R.L.', '9384759090', '77001155', 10.50, 1.50, 'Suspendido');
  INSERT INTO EMPRESA_DELIVERY VALUES (3089, 'Transporte Urbano Plus', '1928373091', '3-3449988', 13.50, 2.00, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3090, 'Paquetería Ágil', '4857390092', '71006622', 11.00, 1.70, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3091, 'Red Envíos BO', '5847361093', '68112299', 12.50, 1.90, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3092, 'ClicDelivery', '2938474094', '2-2449900', 14.50, 2.30, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3093, 'Bolivian Fast Track', '1029383095', '75009944', 15.50, 2.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3094, 'Todo Envío Bolivia', '3948572096', '77006611', 13.00, 2.10, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3095, 'Express Box', '8475639097', '3-3224455', 11.50, 1.80, 'Inactivo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3096, 'Envíos Estrella', '5748392098', '71551122', 12.00, 1.90, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3097, 'Servicio Moto Plus', '9384750099', '68004411', 10.00, 1.50, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3098, 'Pide Lo Que Sea BO', '1928374100', '2-2905566', 14.00, 2.20, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3099, 'Entrega Segura SRL', '4857391101', '75003311', 13.50, 2.00, 'Activo');
  INSERT INTO EMPRESA_DELIVERY VALUES (3100, 'Bolivia Express Courier', '5847362102', '77008822', 15.00, 2.40, 'Activo');

  COMMIT;
END;
 

--REPARTIDOR

BEGIN
  INSERT INTO REPARTIDOR VALUES (1001, 'LIC1001', 'Disponible', 'Moto', 1500.00, 3001);
  INSERT INTO REPARTIDOR VALUES (1002, 'LIC1002', 'Ocupado', 'Auto', 1510.00, 3001);
  INSERT INTO REPARTIDOR VALUES (1003, NULL, 'Fuera de servicio', 'Bicicleta', 1520.00, 3001);
  INSERT INTO REPARTIDOR VALUES (1004, 'LIC1004', 'Disponible', 'Moto', 1530.00, 3001);
  INSERT INTO REPARTIDOR VALUES (1005, 'LIC1005', 'Ocupado', 'Auto', 1540.00, 3002);
  INSERT INTO REPARTIDOR VALUES (1006, NULL, 'Fuera de servicio', 'Bicicleta', 1550.00, 3002);
  INSERT INTO REPARTIDOR VALUES (1007, 'LIC1007', 'Disponible', 'Moto', 1560.00, 3002);
  INSERT INTO REPARTIDOR VALUES (1008, 'LIC1008', 'Ocupado', 'Auto', 1570.00, 3002);
  INSERT INTO REPARTIDOR VALUES (1009, NULL, 'Fuera de servicio', 'Bicicleta', 1580.00, 3003);
  INSERT INTO REPARTIDOR VALUES (1010, 'LIC1010', 'Disponible', 'Moto', 1590.00, 3003);
  INSERT INTO REPARTIDOR VALUES (1011, 'LIC1011', 'Ocupado', 'Auto', 1600.00, 3003);
  INSERT INTO REPARTIDOR VALUES (1012, NULL, 'Fuera de servicio', 'Bicicleta', 1610.00, 3003);
  INSERT INTO REPARTIDOR VALUES (1013, 'LIC1013', 'Disponible', 'Moto', 1620.00, 3004);
  INSERT INTO REPARTIDOR VALUES (1014, 'LIC1014', 'Ocupado', 'Auto', 1630.00, 3004);
  INSERT INTO REPARTIDOR VALUES (1015, NULL, 'Fuera de servicio', 'Bicicleta', 1640.00, 3004);
  INSERT INTO REPARTIDOR VALUES (1016, 'LIC1016', 'Disponible', 'Moto', 1650.00, 3004);
  INSERT INTO REPARTIDOR VALUES (1017, 'LIC1017', 'Ocupado', 'Auto', 1660.00, 3005);
  INSERT INTO REPARTIDOR VALUES (1018, NULL, 'Fuera de servicio', 'Bicicleta', 1670.00, 3005);
  INSERT INTO REPARTIDOR VALUES (1019, 'LIC1019', 'Disponible', 'Moto', 1680.00, 3005);
  INSERT INTO REPARTIDOR VALUES (1020, 'LIC1020', 'Ocupado', 'Auto', 1690.00, 3005);
  INSERT INTO REPARTIDOR VALUES (1021, NULL, 'Fuera de servicio', 'Bicicleta', 1700.00, 3006);
  INSERT INTO REPARTIDOR VALUES (1022, 'LIC1022', 'Disponible', 'Moto', 1710.00, 3006);
  INSERT INTO REPARTIDOR VALUES (1023, 'LIC1023', 'Ocupado', 'Auto', 1720.00, 3006);
  INSERT INTO REPARTIDOR VALUES (1024, NULL, 'Fuera de servicio', 'Bicicleta', 1730.00, 3006);
  INSERT INTO REPARTIDOR VALUES (1025, 'LIC1025', 'Disponible', 'Moto', 1740.00, 3007);
  INSERT INTO REPARTIDOR VALUES (1026, 'LIC1026', 'Ocupado', 'Auto', 1750.00, 3007);
  INSERT INTO REPARTIDOR VALUES (1027, NULL, 'Fuera de servicio', 'Bicicleta', 1760.00, 3007);
  INSERT INTO REPARTIDOR VALUES (1028, 'LIC1028', 'Disponible', 'Moto', 1770.00, 3007);
  INSERT INTO REPARTIDOR VALUES (1029, 'LIC1029', 'Ocupado', 'Auto', 1780.00, 3008);
  INSERT INTO REPARTIDOR VALUES (1030, NULL, 'Fuera de servicio', 'Bicicleta', 1790.00, 3008);
  INSERT INTO REPARTIDOR VALUES (1031, 'LIC1031', 'Disponible', 'Moto', 1800.00, 3008);
  INSERT INTO REPARTIDOR VALUES (1032, 'LIC1032', 'Ocupado', 'Auto', 1810.00, 3008);
  INSERT INTO REPARTIDOR VALUES (1033, NULL, 'Fuera de servicio', 'Bicicleta', 1820.00, 3009);
  INSERT INTO REPARTIDOR VALUES (1034, 'LIC1034', 'Disponible', 'Moto', 1830.00, 3009);
  INSERT INTO REPARTIDOR VALUES (1035, 'LIC1035', 'Ocupado', 'Auto', 1840.00, 3009);
  INSERT INTO REPARTIDOR VALUES (1036, NULL, 'Fuera de servicio', 'Bicicleta', 1850.00, 3009);
  INSERT INTO REPARTIDOR VALUES (1037, 'LIC1037', 'Disponible', 'Moto', 1860.00, 3010);
  INSERT INTO REPARTIDOR VALUES (1038, 'LIC1038', 'Ocupado', 'Auto', 1870.00, 3010);
  INSERT INTO REPARTIDOR VALUES (1039, NULL, 'Fuera de servicio', 'Bicicleta', 1880.00, 3010);
  INSERT INTO REPARTIDOR VALUES (1040, 'LIC1040', 'Disponible', 'Moto', 1890.00, 3010);
  INSERT INTO REPARTIDOR VALUES (1041, 'LIC1041', 'Ocupado', 'Auto', 1900.00, 3011);
  INSERT INTO REPARTIDOR VALUES (1042, NULL, 'Fuera de servicio', 'Bicicleta', 1910.00, 3011);
  INSERT INTO REPARTIDOR VALUES (1043, 'LIC1043', 'Disponible', 'Moto', 1920.00, 3011);
  INSERT INTO REPARTIDOR VALUES (1044, 'LIC1044', 'Ocupado', 'Auto', 1930.00, 3011);
  INSERT INTO REPARTIDOR VALUES (1045, NULL, 'Fuera de servicio', 'Bicicleta', 1940.00, 3012);
  INSERT INTO REPARTIDOR VALUES (1046, 'LIC1046', 'Disponible', 'Moto', 1950.00, 3012);
  INSERT INTO REPARTIDOR VALUES (1047, 'LIC1047', 'Ocupado', 'Auto', 1960.00, 3012);
  INSERT INTO REPARTIDOR VALUES (1048, NULL, 'Fuera de servicio', 'Bicicleta', 1970.00, 3012);
  INSERT INTO REPARTIDOR VALUES (1049, 'LIC1049', 'Disponible', 'Moto', 1980.00, 3013);
  INSERT INTO REPARTIDOR VALUES (1050, 'LIC1050', 'Ocupado', 'Auto', 1990.00, 3013);
  INSERT INTO REPARTIDOR VALUES (1051, NULL, 'Fuera de servicio', 'Bicicleta', 2000.00, 3013);
  INSERT INTO REPARTIDOR VALUES (1052, 'LIC1052', 'Disponible', 'Moto', 2010.00, 3013);
  INSERT INTO REPARTIDOR VALUES (1053, 'LIC1053', 'Ocupado', 'Auto', 2020.00, 3014);
  INSERT INTO REPARTIDOR VALUES (1054, NULL, 'Fuera de servicio', 'Bicicleta', 2030.00, 3014);
  INSERT INTO REPARTIDOR VALUES (1055, 'LIC1055', 'Disponible', 'Moto', 2040.00, 3014);
  INSERT INTO REPARTIDOR VALUES (1056, 'LIC1056', 'Ocupado', 'Auto', 2050.00, 3014);
  INSERT INTO REPARTIDOR VALUES (1057, NULL, 'Fuera de servicio', 'Bicicleta', 2060.00, 3015);
  INSERT INTO REPARTIDOR VALUES (1058, 'LIC1058', 'Disponible', 'Moto', 2070.00, 3015);
  INSERT INTO REPARTIDOR VALUES (1059, 'LIC1059', 'Ocupado', 'Auto', 2080.00, 3015);
  INSERT INTO REPARTIDOR VALUES (1060, NULL, 'Fuera de servicio', 'Bicicleta', 2090.00, 3015);
  INSERT INTO REPARTIDOR VALUES (1061, 'LIC1061', 'Disponible', 'Moto', 2100.00, 3016);
  INSERT INTO REPARTIDOR VALUES (1062, 'LIC1062', 'Ocupado', 'Auto', 2110.00, 3016);
  INSERT INTO REPARTIDOR VALUES (1063, NULL, 'Fuera de servicio', 'Bicicleta', 2120.00, 3016);
  INSERT INTO REPARTIDOR VALUES (1064, 'LIC1064', 'Disponible', 'Moto', 2130.00, 3016);
  INSERT INTO REPARTIDOR VALUES (1065, 'LIC1065', 'Ocupado', 'Auto', 2140.00, 3017);
  INSERT INTO REPARTIDOR VALUES (1066, NULL, 'Fuera de servicio', 'Bicicleta', 2150.00, 3017);
  INSERT INTO REPARTIDOR VALUES (1067, 'LIC1067', 'Disponible', 'Moto', 2160.00, 3017);
  INSERT INTO REPARTIDOR VALUES (1068, 'LIC1068', 'Ocupado', 'Auto', 2170.00, 3017);
  INSERT INTO REPARTIDOR VALUES (1069, NULL, 'Fuera de servicio', 'Bicicleta', 2180.00, 3018);
  INSERT INTO REPARTIDOR VALUES (1070, 'LIC1070', 'Disponible', 'Moto', 2190.00, 3018);
  INSERT INTO REPARTIDOR VALUES (1071, 'LIC1071', 'Ocupado', 'Auto', 2200.00, 3018);
  INSERT INTO REPARTIDOR VALUES (1072, NULL, 'Fuera de servicio', 'Bicicleta', 2210.00, 3018);
  INSERT INTO REPARTIDOR VALUES (1073, 'LIC1073', 'Disponible', 'Moto', 2220.00, 3019);
  INSERT INTO REPARTIDOR VALUES (1074, 'LIC1074', 'Ocupado', 'Auto', 2230.00, 3019);
  INSERT INTO REPARTIDOR VALUES (1075, NULL, 'Fuera de servicio', 'Bicicleta', 2240.00, 3019);
  INSERT INTO REPARTIDOR VALUES (1076, 'LIC1076', 'Disponible', 'Moto', 2250.00, 3019);
  INSERT INTO REPARTIDOR VALUES (1077, 'LIC1077', 'Ocupado', 'Auto', 2260.00, 3020);
  INSERT INTO REPARTIDOR VALUES (1078, NULL, 'Fuera de servicio', 'Bicicleta', 2270.00, 3020);
  INSERT INTO REPARTIDOR VALUES (1079, 'LIC1079', 'Disponible', 'Moto', 2280.00, 3020);
  INSERT INTO REPARTIDOR VALUES (1080, 'LIC1080', 'Ocupado', 'Auto', 2290.00, 3020);
  INSERT INTO REPARTIDOR VALUES (1081, NULL, 'Fuera de servicio', 'Bicicleta', 2300.00, 3021);
  INSERT INTO REPARTIDOR VALUES (1082, 'LIC1082', 'Disponible', 'Moto', 2310.00, 3021);
  INSERT INTO REPARTIDOR VALUES (1083, 'LIC1083', 'Ocupado', 'Auto', 2320.00, 3021);
  INSERT INTO REPARTIDOR VALUES (1084, NULL, 'Fuera de servicio', 'Bicicleta', 2330.00, 3021);
  INSERT INTO REPARTIDOR VALUES (1085, 'LIC1085', 'Disponible', 'Moto', 2340.00, 3022);
  INSERT INTO REPARTIDOR VALUES (1086, 'LIC1086', 'Ocupado', 'Auto', 2350.00, 3022);
  INSERT INTO REPARTIDOR VALUES (1087, NULL, 'Fuera de servicio', 'Bicicleta', 2360.00, 3022);
  INSERT INTO REPARTIDOR VALUES (1088, 'LIC1088', 'Disponible', 'Moto', 2370.00, 3022);
  INSERT INTO REPARTIDOR VALUES (1089, 'LIC1089', 'Ocupado', 'Auto', 2380.00, 3023);
  INSERT INTO REPARTIDOR VALUES (1090, NULL, 'Fuera de servicio', 'Bicicleta', 2390.00, 3023);
  INSERT INTO REPARTIDOR VALUES (1091, 'LIC1091', 'Disponible', 'Moto', 2400.00, 3023);
  INSERT INTO REPARTIDOR VALUES (1092, 'LIC1092', 'Ocupado', 'Auto', 2410.00, 3023);
  INSERT INTO REPARTIDOR VALUES (1093, NULL, 'Fuera de servicio', 'Bicicleta', 2420.00, 3024);
  INSERT INTO REPARTIDOR VALUES (1094, 'LIC1094', 'Disponible', 'Moto', 2430.00, 3024);
  INSERT INTO REPARTIDOR VALUES (1095, 'LIC1095', 'Ocupado', 'Auto', 2440.00, 3024);
  INSERT INTO REPARTIDOR VALUES (1096, NULL, 'Fuera de servicio', 'Bicicleta', 2450.00, 3024);
  INSERT INTO REPARTIDOR VALUES (1097, 'LIC1097', 'Disponible', 'Moto', 2460.00, 3025);
  INSERT INTO REPARTIDOR VALUES (1098, 'LIC1098', 'Ocupado', 'Auto', 2470.00, 3025);
  INSERT INTO REPARTIDOR VALUES (1099, NULL, 'Fuera de servicio', 'Bicicleta', 2480.00, 3025);
  INSERT INTO REPARTIDOR VALUES (1100, 'LIC1100', 'Disponible', 'Moto', 2490.00, 3025);
  COMMIT;
END;

BEGIN
  INSERT INTO REPARTIDOR VALUES (1101, 'LIC1101', 'Ocupado', 'Auto', 2500.00, 3026);
  INSERT INTO REPARTIDOR VALUES (1102, NULL, 'Fuera de servicio', 'Bicicleta', 2510.00, 3026);
  INSERT INTO REPARTIDOR VALUES (1103, 'LIC1103', 'Disponible', 'Moto', 2520.00, 3026);
  INSERT INTO REPARTIDOR VALUES (1104, 'LIC1104', 'Ocupado', 'Auto', 2530.00, 3026);
  INSERT INTO REPARTIDOR VALUES (1105, NULL, 'Fuera de servicio', 'Bicicleta', 2540.00, 3027);
  INSERT INTO REPARTIDOR VALUES (1106, 'LIC1106', 'Disponible', 'Moto', 2550.00, 3027);
  INSERT INTO REPARTIDOR VALUES (1107, 'LIC1107', 'Ocupado', 'Auto', 2560.00, 3027);
  INSERT INTO REPARTIDOR VALUES (1108, NULL, 'Fuera de servicio', 'Bicicleta', 2570.00, 3027);
  INSERT INTO REPARTIDOR VALUES (1109, 'LIC1109', 'Disponible', 'Moto', 2580.00, 3028);
  INSERT INTO REPARTIDOR VALUES (1110, 'LIC1110', 'Ocupado', 'Auto', 2590.00, 3028);
  INSERT INTO REPARTIDOR VALUES (1111, NULL, 'Fuera de servicio', 'Bicicleta', 2600.00, 3028);
  INSERT INTO REPARTIDOR VALUES (1112, 'LIC1112', 'Disponible', 'Moto', 2610.00, 3028);
  INSERT INTO REPARTIDOR VALUES (1113, 'LIC1113', 'Ocupado', 'Auto', 2620.00, 3029);
  INSERT INTO REPARTIDOR VALUES (1114, NULL, 'Fuera de servicio', 'Bicicleta', 2630.00, 3029);
  INSERT INTO REPARTIDOR VALUES (1115, 'LIC1115', 'Disponible', 'Moto', 2640.00, 3029);
  INSERT INTO REPARTIDOR VALUES (1116, 'LIC1116', 'Ocupado', 'Auto', 2650.00, 3029);
  INSERT INTO REPARTIDOR VALUES (1117, NULL, 'Fuera de servicio', 'Bicicleta', 2660.00, 3030);
  INSERT INTO REPARTIDOR VALUES (1118, 'LIC1118', 'Disponible', 'Moto', 2670.00, 3030);
  INSERT INTO REPARTIDOR VALUES (1119, 'LIC1119', 'Ocupado', 'Auto', 2680.00, 3030);
  INSERT INTO REPARTIDOR VALUES (1120, NULL, 'Fuera de servicio', 'Bicicleta', 2690.00, 3030);
  INSERT INTO REPARTIDOR VALUES (1121, 'LIC1121', 'Disponible', 'Moto', 2700.00, 3031);
  INSERT INTO REPARTIDOR VALUES (1122, 'LIC1122', 'Ocupado', 'Auto', 2710.00, 3031);
  INSERT INTO REPARTIDOR VALUES (1123, NULL, 'Fuera de servicio', 'Bicicleta', 2720.00, 3031);
  INSERT INTO REPARTIDOR VALUES (1124, 'LIC1124', 'Disponible', 'Moto', 2730.00, 3031);
  INSERT INTO REPARTIDOR VALUES (1125, 'LIC1125', 'Ocupado', 'Auto', 2740.00, 3032);
  INSERT INTO REPARTIDOR VALUES (1126, NULL, 'Fuera de servicio', 'Bicicleta', 2750.00, 3032);
  INSERT INTO REPARTIDOR VALUES (1127, 'LIC1127', 'Disponible', 'Moto', 2760.00, 3032);
  INSERT INTO REPARTIDOR VALUES (1128, 'LIC1128', 'Ocupado', 'Auto', 2770.00, 3032);
  INSERT INTO REPARTIDOR VALUES (1129, NULL, 'Fuera de servicio', 'Bicicleta', 2780.00, 3033);
  INSERT INTO REPARTIDOR VALUES (1130, 'LIC1130', 'Disponible', 'Moto', 2790.00, 3033);
  INSERT INTO REPARTIDOR VALUES (1131, 'LIC1131', 'Ocupado', 'Auto', 2800.00, 3033);
  INSERT INTO REPARTIDOR VALUES (1132, NULL, 'Fuera de servicio', 'Bicicleta', 2810.00, 3033);
  INSERT INTO REPARTIDOR VALUES (1133, 'LIC1133', 'Disponible', 'Moto', 2820.00, 3034);
  INSERT INTO REPARTIDOR VALUES (1134, 'LIC1134', 'Ocupado', 'Auto', 2830.00, 3034);
  INSERT INTO REPARTIDOR VALUES (1135, NULL, 'Fuera de servicio', 'Bicicleta', 2840.00, 3034);
  INSERT INTO REPARTIDOR VALUES (1136, 'LIC1136', 'Disponible', 'Moto', 2850.00, 3034);
  INSERT INTO REPARTIDOR VALUES (1137, 'LIC1137', 'Ocupado', 'Auto', 2860.00, 3035);
  INSERT INTO REPARTIDOR VALUES (1138, NULL, 'Fuera de servicio', 'Bicicleta', 2870.00, 3035);
  INSERT INTO REPARTIDOR VALUES (1139, 'LIC1139', 'Disponible', 'Moto', 2880.00, 3035);
  INSERT INTO REPARTIDOR VALUES (1140, 'LIC1140', 'Ocupado', 'Auto', 2890.00, 3035);
  INSERT INTO REPARTIDOR VALUES (1141, NULL, 'Fuera de servicio', 'Bicicleta', 2900.00, 3036);
  INSERT INTO REPARTIDOR VALUES (1142, 'LIC1142', 'Disponible', 'Moto', 2910.00, 3036);
  INSERT INTO REPARTIDOR VALUES (1143, 'LIC1143', 'Ocupado', 'Auto', 2920.00, 3036);
  INSERT INTO REPARTIDOR VALUES (1144, NULL, 'Fuera de servicio', 'Bicicleta', 2930.00, 3036);
  INSERT INTO REPARTIDOR VALUES (1145, 'LIC1145', 'Disponible', 'Moto', 2940.00, 3037);
  INSERT INTO REPARTIDOR VALUES (1146, 'LIC1146', 'Ocupado', 'Auto', 2950.00, 3037);
  INSERT INTO REPARTIDOR VALUES (1147, NULL, 'Fuera de servicio', 'Bicicleta', 2960.00, 3037);
  INSERT INTO REPARTIDOR VALUES (1148, 'LIC1148', 'Disponible', 'Moto', 2970.00, 3037);
  INSERT INTO REPARTIDOR VALUES (1149, 'LIC1149', 'Ocupado', 'Auto', 2980.00, 3038);
  INSERT INTO REPARTIDOR VALUES (1150, NULL, 'Fuera de servicio', 'Bicicleta', 2990.00, 3038);
  INSERT INTO REPARTIDOR VALUES (1151, 'LIC1151', 'Disponible', 'Moto', 3000.00, 3038);
  INSERT INTO REPARTIDOR VALUES (1152, 'LIC1152', 'Ocupado', 'Auto', 3010.00, 3038);
  INSERT INTO REPARTIDOR VALUES (1153, NULL, 'Fuera de servicio', 'Bicicleta', 3020.00, 3039);
  INSERT INTO REPARTIDOR VALUES (1154, 'LIC1154', 'Disponible', 'Moto', 3030.00, 3039);
  INSERT INTO REPARTIDOR VALUES (1155, 'LIC1155', 'Ocupado', 'Auto', 3040.00, 3039);
  INSERT INTO REPARTIDOR VALUES (1156, NULL, 'Fuera de servicio', 'Bicicleta', 3050.00, 3039);
  INSERT INTO REPARTIDOR VALUES (1157, 'LIC1157', 'Disponible', 'Moto', 3060.00, 3040);
  INSERT INTO REPARTIDOR VALUES (1158, 'LIC1158', 'Ocupado', 'Auto', 3070.00, 3040);
  INSERT INTO REPARTIDOR VALUES (1159, NULL, 'Fuera de servicio', 'Bicicleta', 3080.00, 3040);
  INSERT INTO REPARTIDOR VALUES (1160, 'LIC1160', 'Disponible', 'Moto', 3090.00, 3040);
  INSERT INTO REPARTIDOR VALUES (1161, 'LIC1161', 'Ocupado', 'Auto', 3100.00, 3041);
  INSERT INTO REPARTIDOR VALUES (1162, NULL, 'Fuera de servicio', 'Bicicleta', 3110.00, 3041);
  INSERT INTO REPARTIDOR VALUES (1163, 'LIC1163', 'Disponible', 'Moto', 3120.00, 3041);
  INSERT INTO REPARTIDOR VALUES (1164, 'LIC1164', 'Ocupado', 'Auto', 3130.00, 3041);
  INSERT INTO REPARTIDOR VALUES (1165, NULL, 'Fuera de servicio', 'Bicicleta', 3140.00, 3042);
  INSERT INTO REPARTIDOR VALUES (1166, 'LIC1166', 'Disponible', 'Moto', 3150.00, 3042);
  INSERT INTO REPARTIDOR VALUES (1167, 'LIC1167', 'Ocupado', 'Auto', 3160.00, 3042);
  INSERT INTO REPARTIDOR VALUES (1168, NULL, 'Fuera de servicio', 'Bicicleta', 3170.00, 3042);
  INSERT INTO REPARTIDOR VALUES (1169, 'LIC1169', 'Disponible', 'Moto', 3180.00, 3043);
  INSERT INTO REPARTIDOR VALUES (1170, 'LIC1170', 'Ocupado', 'Auto', 3190.00, 3043);
  INSERT INTO REPARTIDOR VALUES (1171, NULL, 'Fuera de servicio', 'Bicicleta', 3200.00, 3043);
  INSERT INTO REPARTIDOR VALUES (1172, 'LIC1172', 'Disponible', 'Moto', 3210.00, 3043);
  INSERT INTO REPARTIDOR VALUES (1173, 'LIC1173', 'Ocupado', 'Auto', 3220.00, 3044);
  INSERT INTO REPARTIDOR VALUES (1174, NULL, 'Fuera de servicio', 'Bicicleta', 3230.00, 3044);
  INSERT INTO REPARTIDOR VALUES (1175, 'LIC1175', 'Disponible', 'Moto', 3240.00, 3044);
  INSERT INTO REPARTIDOR VALUES (1176, 'LIC1176', 'Ocupado', 'Auto', 3250.00, 3044);
  INSERT INTO REPARTIDOR VALUES (1177, NULL, 'Fuera de servicio', 'Bicicleta', 3260.00, 3045);
  INSERT INTO REPARTIDOR VALUES (1178, 'LIC1178', 'Disponible', 'Moto', 3270.00, 3045);
  INSERT INTO REPARTIDOR VALUES (1179, 'LIC1179', 'Ocupado', 'Auto', 3280.00, 3045);
  INSERT INTO REPARTIDOR VALUES (1180, NULL, 'Fuera de servicio', 'Bicicleta', 3290.00, 3045);
  INSERT INTO REPARTIDOR VALUES (1181, 'LIC1181', 'Disponible', 'Moto', 3300.00, 3046);
  INSERT INTO REPARTIDOR VALUES (1182, 'LIC1182', 'Ocupado', 'Auto', 3310.00, 3046);
  INSERT INTO REPARTIDOR VALUES (1183, NULL, 'Fuera de servicio', 'Bicicleta', 3320.00, 3046);
  INSERT INTO REPARTIDOR VALUES (1184, 'LIC1184', 'Disponible', 'Moto', 3330.00, 3046);
  INSERT INTO REPARTIDOR VALUES (1185, 'LIC1185', 'Ocupado', 'Auto', 3340.00, 3047);
  INSERT INTO REPARTIDOR VALUES (1186, NULL, 'Fuera de servicio', 'Bicicleta', 3350.00, 3047);
  INSERT INTO REPARTIDOR VALUES (1187, 'LIC1187', 'Disponible', 'Moto', 3360.00, 3047);
  INSERT INTO REPARTIDOR VALUES (1188, 'LIC1188', 'Ocupado', 'Auto', 3370.00, 3047);
  INSERT INTO REPARTIDOR VALUES (1189, NULL, 'Fuera de servicio', 'Bicicleta', 3380.00, 3048);
  INSERT INTO REPARTIDOR VALUES (1190, 'LIC1190', 'Disponible', 'Moto', 3390.00, 3048);
  INSERT INTO REPARTIDOR VALUES (1191, 'LIC1191', 'Ocupado', 'Auto', 3400.00, 3048);
  INSERT INTO REPARTIDOR VALUES (1192, NULL, 'Fuera de servicio', 'Bicicleta', 3410.00, 3048);
  INSERT INTO REPARTIDOR VALUES (1193, 'LIC1193', 'Disponible', 'Moto', 3420.00, 3049);
  INSERT INTO REPARTIDOR VALUES (1194, 'LIC1194', 'Ocupado', 'Auto', 3430.00, 3049);
  INSERT INTO REPARTIDOR VALUES (1195, NULL, 'Fuera de servicio', 'Bicicleta', 3440.00, 3049);
  INSERT INTO REPARTIDOR VALUES (1196, 'LIC1196', 'Disponible', 'Moto', 3450.00, 3049);
  INSERT INTO REPARTIDOR VALUES (1197, 'LIC1197', 'Ocupado', 'Auto', 3460.00, 3050);
  INSERT INTO REPARTIDOR VALUES (1198, NULL, 'Fuera de servicio', 'Bicicleta', 3470.00, 3050);
  INSERT INTO REPARTIDOR VALUES (1199, 'LIC1199', 'Disponible', 'Moto', 3480.00, 3050);
  INSERT INTO REPARTIDOR VALUES (1200, 'LIC1200', 'Ocupado', 'Auto', 3490.00, 3050);
  COMMIT;
END;
 

BEGIN
  INSERT INTO REPARTIDOR VALUES (1201, NULL, 'Fuera de servicio', 'Bicicleta', 1500.00, 3051);
  INSERT INTO REPARTIDOR VALUES (1202, 'LIC1202', 'Disponible', 'Moto', 1510.00, 3051);
  INSERT INTO REPARTIDOR VALUES (1203, 'LIC1203', 'Ocupado', 'Auto', 1520.00, 3051);
  INSERT INTO REPARTIDOR VALUES (1204, NULL, 'Fuera de servicio', 'Bicicleta', 1530.00, 3051);
  INSERT INTO REPARTIDOR VALUES (1205, 'LIC1205', 'Disponible', 'Moto', 1540.00, 3051);
  INSERT INTO REPARTIDOR VALUES (1206, 'LIC1206', 'Ocupado', 'Auto', 1550.00, 3052);
  INSERT INTO REPARTIDOR VALUES (1207, NULL, 'Fuera de servicio', 'Bicicleta', 1560.00, 3052);
  INSERT INTO REPARTIDOR VALUES (1208, 'LIC1208', 'Disponible', 'Moto', 1570.00, 3052);
  INSERT INTO REPARTIDOR VALUES (1209, 'LIC1209', 'Ocupado', 'Auto', 1580.00, 3052);
  INSERT INTO REPARTIDOR VALUES (1210, NULL, 'Fuera de servicio', 'Bicicleta', 1590.00, 3052);
  INSERT INTO REPARTIDOR VALUES (1211, 'LIC1211', 'Disponible', 'Moto', 1600.00, 3053);
  INSERT INTO REPARTIDOR VALUES (1212, 'LIC1212', 'Ocupado', 'Auto', 1610.00, 3053);
  INSERT INTO REPARTIDOR VALUES (1213, NULL, 'Fuera de servicio', 'Bicicleta', 1620.00, 3053);
  INSERT INTO REPARTIDOR VALUES (1214, 'LIC1214', 'Disponible', 'Moto', 1630.00, 3053);
  INSERT INTO REPARTIDOR VALUES (1215, 'LIC1215', 'Ocupado', 'Auto', 1640.00, 3053);
  INSERT INTO REPARTIDOR VALUES (1216, NULL, 'Fuera de servicio', 'Bicicleta', 1650.00, 3054);
  INSERT INTO REPARTIDOR VALUES (1217, 'LIC1217', 'Disponible', 'Moto', 1660.00, 3054);
  INSERT INTO REPARTIDOR VALUES (1218, 'LIC1218', 'Ocupado', 'Auto', 1670.00, 3054);
  INSERT INTO REPARTIDOR VALUES (1219, NULL, 'Fuera de servicio', 'Bicicleta', 1680.00, 3054);
  INSERT INTO REPARTIDOR VALUES (1220, 'LIC1220', 'Disponible', 'Moto', 1690.00, 3054);
  INSERT INTO REPARTIDOR VALUES (1221, 'LIC1221', 'Ocupado', 'Auto', 1700.00, 3055);
  INSERT INTO REPARTIDOR VALUES (1222, NULL, 'Fuera de servicio', 'Bicicleta', 1710.00, 3055);
  INSERT INTO REPARTIDOR VALUES (1223, 'LIC1223', 'Disponible', 'Moto', 1720.00, 3055);
  INSERT INTO REPARTIDOR VALUES (1224, 'LIC1224', 'Ocupado', 'Auto', 1730.00, 3055);
  INSERT INTO REPARTIDOR VALUES (1225, NULL, 'Fuera de servicio', 'Bicicleta', 1740.00, 3055);
  INSERT INTO REPARTIDOR VALUES (1226, 'LIC1226', 'Disponible', 'Moto', 1750.00, 3056);
  INSERT INTO REPARTIDOR VALUES (1227, 'LIC1227', 'Ocupado', 'Auto', 1760.00, 3056);
  INSERT INTO REPARTIDOR VALUES (1228, NULL, 'Fuera de servicio', 'Bicicleta', 1770.00, 3056);
  INSERT INTO REPARTIDOR VALUES (1229, 'LIC1229', 'Disponible', 'Moto', 1780.00, 3056);
  INSERT INTO REPARTIDOR VALUES (1230, 'LIC1230', 'Ocupado', 'Auto', 1790.00, 3056);
  INSERT INTO REPARTIDOR VALUES (1231, NULL, 'Fuera de servicio', 'Bicicleta', 1800.00, 3057);
  INSERT INTO REPARTIDOR VALUES (1232, 'LIC1232', 'Disponible', 'Moto', 1810.00, 3057);
  INSERT INTO REPARTIDOR VALUES (1233, 'LIC1233', 'Ocupado', 'Auto', 1820.00, 3057);
  INSERT INTO REPARTIDOR VALUES (1234, NULL, 'Fuera de servicio', 'Bicicleta', 1830.00, 3057);
  INSERT INTO REPARTIDOR VALUES (1235, 'LIC1235', 'Disponible', 'Moto', 1840.00, 3057);
  INSERT INTO REPARTIDOR VALUES (1236, 'LIC1236', 'Ocupado', 'Auto', 1850.00, 3058);
  INSERT INTO REPARTIDOR VALUES (1237, NULL, 'Fuera de servicio', 'Bicicleta', 1860.00, 3058);
  INSERT INTO REPARTIDOR VALUES (1238, 'LIC1238', 'Disponible', 'Moto', 1870.00, 3058);
  INSERT INTO REPARTIDOR VALUES (1239, 'LIC1239', 'Ocupado', 'Auto', 1880.00, 3058);
  INSERT INTO REPARTIDOR VALUES (1240, NULL, 'Fuera de servicio', 'Bicicleta', 1890.00, 3058);
  INSERT INTO REPARTIDOR VALUES (1241, 'LIC1241', 'Disponible', 'Moto', 1900.00, 3059);
  INSERT INTO REPARTIDOR VALUES (1242, 'LIC1242', 'Ocupado', 'Auto', 1910.00, 3059);
  INSERT INTO REPARTIDOR VALUES (1243, NULL, 'Fuera de servicio', 'Bicicleta', 1920.00, 3059);
  INSERT INTO REPARTIDOR VALUES (1244, 'LIC1244', 'Disponible', 'Moto', 1930.00, 3059);
  INSERT INTO REPARTIDOR VALUES (1245, 'LIC1245', 'Ocupado', 'Auto', 1940.00, 3059);
  INSERT INTO REPARTIDOR VALUES (1246, NULL, 'Fuera de servicio', 'Bicicleta', 1950.00, 3060);
  INSERT INTO REPARTIDOR VALUES (1247, 'LIC1247', 'Disponible', 'Moto', 1960.00, 3060);
  INSERT INTO REPARTIDOR VALUES (1248, 'LIC1248', 'Ocupado', 'Auto', 1970.00, 3060);
  INSERT INTO REPARTIDOR VALUES (1249, NULL, 'Fuera de servicio', 'Bicicleta', 1980.00, 3060);
  INSERT INTO REPARTIDOR VALUES (1250, 'LIC1250', 'Disponible', 'Moto', 1990.00, 3060);
  INSERT INTO REPARTIDOR VALUES (1251, 'LIC1251', 'Ocupado', 'Auto', 2000.00, 3061);
  INSERT INTO REPARTIDOR VALUES (1252, NULL, 'Fuera de servicio', 'Bicicleta', 2010.00, 3061);
  INSERT INTO REPARTIDOR VALUES (1253, 'LIC1253', 'Disponible', 'Moto', 2020.00, 3061);
  INSERT INTO REPARTIDOR VALUES (1254, 'LIC1254', 'Ocupado', 'Auto', 2030.00, 3061);
  INSERT INTO REPARTIDOR VALUES (1255, NULL, 'Fuera de servicio', 'Bicicleta', 2040.00, 3061);
  INSERT INTO REPARTIDOR VALUES (1256, 'LIC1256', 'Disponible', 'Moto', 2050.00, 3062);
  INSERT INTO REPARTIDOR VALUES (1257, 'LIC1257', 'Ocupado', 'Auto', 2060.00, 3062);
  INSERT INTO REPARTIDOR VALUES (1258, NULL, 'Fuera de servicio', 'Bicicleta', 2070.00, 3062);
  INSERT INTO REPARTIDOR VALUES (1259, 'LIC1259', 'Disponible', 'Moto', 2080.00, 3062);
  INSERT INTO REPARTIDOR VALUES (1260, 'LIC1260', 'Ocupado', 'Auto', 2090.00, 3062);
  INSERT INTO REPARTIDOR VALUES (1261, NULL, 'Fuera de servicio', 'Bicicleta', 2100.00, 3063);
  INSERT INTO REPARTIDOR VALUES (1262, 'LIC1262', 'Disponible', 'Moto', 2110.00, 3063);
  INSERT INTO REPARTIDOR VALUES (1263, 'LIC1263', 'Ocupado', 'Auto', 2120.00, 3063);
  INSERT INTO REPARTIDOR VALUES (1264, NULL, 'Fuera de servicio', 'Bicicleta', 2130.00, 3063);
  INSERT INTO REPARTIDOR VALUES (1265, 'LIC1265', 'Disponible', 'Moto', 2140.00, 3063);
  INSERT INTO REPARTIDOR VALUES (1266, 'LIC1266', 'Ocupado', 'Auto', 2150.00, 3064);
  INSERT INTO REPARTIDOR VALUES (1267, NULL, 'Fuera de servicio', 'Bicicleta', 2160.00, 3064);
  INSERT INTO REPARTIDOR VALUES (1268, 'LIC1268', 'Disponible', 'Moto', 2170.00, 3064);
  INSERT INTO REPARTIDOR VALUES (1269, 'LIC1269', 'Ocupado', 'Auto', 2180.00, 3064);
  INSERT INTO REPARTIDOR VALUES (1270, NULL, 'Fuera de servicio', 'Bicicleta', 2190.00, 3064);
  INSERT INTO REPARTIDOR VALUES (1271, 'LIC1271', 'Disponible', 'Moto', 2200.00, 3065);
  INSERT INTO REPARTIDOR VALUES (1272, 'LIC1272', 'Ocupado', 'Auto', 2210.00, 3065);
  INSERT INTO REPARTIDOR VALUES (1273, NULL, 'Fuera de servicio', 'Bicicleta', 2220.00, 3065);
  INSERT INTO REPARTIDOR VALUES (1274, 'LIC1274', 'Disponible', 'Moto', 2230.00, 3065);
  INSERT INTO REPARTIDOR VALUES (1275, 'LIC1275', 'Ocupado', 'Auto', 2240.00, 3065);
  INSERT INTO REPARTIDOR VALUES (1276, NULL, 'Fuera de servicio', 'Bicicleta', 2250.00, 3066);
  INSERT INTO REPARTIDOR VALUES (1277, 'LIC1277', 'Disponible', 'Moto', 2260.00, 3066);
  INSERT INTO REPARTIDOR VALUES (1278, 'LIC1278', 'Ocupado', 'Auto', 2270.00, 3066);
  INSERT INTO REPARTIDOR VALUES (1279, NULL, 'Fuera de servicio', 'Bicicleta', 2280.00, 3066);
  INSERT INTO REPARTIDOR VALUES (1280, 'LIC1280', 'Disponible', 'Moto', 2290.00, 3066);
  INSERT INTO REPARTIDOR VALUES (1281, 'LIC1281', 'Ocupado', 'Auto', 2300.00, 3067);
  INSERT INTO REPARTIDOR VALUES (1282, NULL, 'Fuera de servicio', 'Bicicleta', 2310.00, 3067);
  INSERT INTO REPARTIDOR VALUES (1283, 'LIC1283', 'Disponible', 'Moto', 2320.00, 3067);
  INSERT INTO REPARTIDOR VALUES (1284, 'LIC1284', 'Ocupado', 'Auto', 2330.00, 3067);
  INSERT INTO REPARTIDOR VALUES (1285, NULL, 'Fuera de servicio', 'Bicicleta', 2340.00, 3067);
  INSERT INTO REPARTIDOR VALUES (1286, 'LIC1286', 'Disponible', 'Moto', 2350.00, 3068);
  INSERT INTO REPARTIDOR VALUES (1287, 'LIC1287', 'Ocupado', 'Auto', 2360.00, 3068);
  INSERT INTO REPARTIDOR VALUES (1288, NULL, 'Fuera de servicio', 'Bicicleta', 2370.00, 3068);
  INSERT INTO REPARTIDOR VALUES (1289, 'LIC1289', 'Disponible', 'Moto', 2380.00, 3068);
  INSERT INTO REPARTIDOR VALUES (1290, 'LIC1290', 'Ocupado', 'Auto', 2390.00, 3068);
  INSERT INTO REPARTIDOR VALUES (1291, NULL, 'Fuera de servicio', 'Bicicleta', 2400.00, 3069);
  INSERT INTO REPARTIDOR VALUES (1292, 'LIC1292', 'Disponible', 'Moto', 2410.00, 3069);
  INSERT INTO REPARTIDOR VALUES (1293, 'LIC1293', 'Ocupado', 'Auto', 2420.00, 3069);
  INSERT INTO REPARTIDOR VALUES (1294, NULL, 'Fuera de servicio', 'Bicicleta', 2430.00, 3069);
  INSERT INTO REPARTIDOR VALUES (1295, 'LIC1295', 'Disponible', 'Moto', 2440.00, 3069);
  INSERT INTO REPARTIDOR VALUES (1296, 'LIC1296', 'Ocupado', 'Auto', 2450.00, 3070);
  INSERT INTO REPARTIDOR VALUES (1297, NULL, 'Fuera de servicio', 'Bicicleta', 2460.00, 3070);
  INSERT INTO REPARTIDOR VALUES (1298, 'LIC1298', 'Disponible', 'Moto', 2470.00, 3070);
  INSERT INTO REPARTIDOR VALUES (1299, 'LIC1299', 'Ocupado', 'Auto', 2480.00, 3070);
  INSERT INTO REPARTIDOR VALUES (1300, NULL, 'Fuera de servicio', 'Bicicleta', 2490.00, 3070);
  COMMIT;
END;
 

BEGIN
  INSERT INTO REPARTIDOR VALUES (1301, 'LIC1301', 'Disponible', 'Moto', 2500.00, 3071);
  INSERT INTO REPARTIDOR VALUES (1302, 'LIC1302', 'Ocupado', 'Auto', 2510.00, 3071);
  INSERT INTO REPARTIDOR VALUES (1303, NULL, 'Fuera de servicio', 'Bicicleta', 2520.00, 3071);
  INSERT INTO REPARTIDOR VALUES (1304, 'LIC1304', 'Disponible', 'Moto', 2530.00, 3071);
  INSERT INTO REPARTIDOR VALUES (1305, 'LIC1305', 'Ocupado', 'Auto', 2540.00, 3071);
  INSERT INTO REPARTIDOR VALUES (1306, NULL, 'Fuera de servicio', 'Bicicleta', 2550.00, 3072);
  INSERT INTO REPARTIDOR VALUES (1307, 'LIC1307', 'Disponible', 'Moto', 2560.00, 3072);
  INSERT INTO REPARTIDOR VALUES (1308, 'LIC1308', 'Ocupado', 'Auto', 2570.00, 3072);
  INSERT INTO REPARTIDOR VALUES (1309, NULL, 'Fuera de servicio', 'Bicicleta', 2580.00, 3072);
  INSERT INTO REPARTIDOR VALUES (1310, 'LIC1310', 'Disponible', 'Moto', 2590.00, 3072);
  INSERT INTO REPARTIDOR VALUES (1311, 'LIC1311', 'Ocupado', 'Auto', 2600.00, 3073);
  INSERT INTO REPARTIDOR VALUES (1312, NULL, 'Fuera de servicio', 'Bicicleta', 2610.00, 3073);
  INSERT INTO REPARTIDOR VALUES (1313, 'LIC1313', 'Disponible', 'Moto', 2620.00, 3073);
  INSERT INTO REPARTIDOR VALUES (1314, 'LIC1314', 'Ocupado', 'Auto', 2630.00, 3073);
  INSERT INTO REPARTIDOR VALUES (1315, NULL, 'Fuera de servicio', 'Bicicleta', 2640.00, 3073);
  INSERT INTO REPARTIDOR VALUES (1316, 'LIC1316', 'Disponible', 'Moto', 2650.00, 3074);
  INSERT INTO REPARTIDOR VALUES (1317, 'LIC1317', 'Ocupado', 'Auto', 2660.00, 3074);
  INSERT INTO REPARTIDOR VALUES (1318, NULL, 'Fuera de servicio', 'Bicicleta', 2670.00, 3074);
  INSERT INTO REPARTIDOR VALUES (1319, 'LIC1319', 'Disponible', 'Moto', 2680.00, 3074);
  INSERT INTO REPARTIDOR VALUES (1320, 'LIC1320', 'Ocupado', 'Auto', 2690.00, 3074);
  INSERT INTO REPARTIDOR VALUES (1321, NULL, 'Fuera de servicio', 'Bicicleta', 2700.00, 3075);
  INSERT INTO REPARTIDOR VALUES (1322, 'LIC1322', 'Disponible', 'Moto', 2710.00, 3075);
  INSERT INTO REPARTIDOR VALUES (1323, 'LIC1323', 'Ocupado', 'Auto', 2720.00, 3075);
  INSERT INTO REPARTIDOR VALUES (1324, NULL, 'Fuera de servicio', 'Bicicleta', 2730.00, 3075);
  INSERT INTO REPARTIDOR VALUES (1325, 'LIC1325', 'Disponible', 'Moto', 2740.00, 3075);
  INSERT INTO REPARTIDOR VALUES (1326, 'LIC1326', 'Ocupado', 'Auto', 2750.00, 3076);
  INSERT INTO REPARTIDOR VALUES (1327, NULL, 'Fuera de servicio', 'Bicicleta', 2760.00, 3076);
  INSERT INTO REPARTIDOR VALUES (1328, 'LIC1328', 'Disponible', 'Moto', 2770.00, 3076);
  INSERT INTO REPARTIDOR VALUES (1329, 'LIC1329', 'Ocupado', 'Auto', 2780.00, 3076);
  INSERT INTO REPARTIDOR VALUES (1330, NULL, 'Fuera de servicio', 'Bicicleta', 2790.00, 3076);
  INSERT INTO REPARTIDOR VALUES (1331, 'LIC1331', 'Disponible', 'Moto', 2800.00, 3077);
  INSERT INTO REPARTIDOR VALUES (1332, 'LIC1332', 'Ocupado', 'Auto', 2810.00, 3077);
  INSERT INTO REPARTIDOR VALUES (1333, NULL, 'Fuera de servicio', 'Bicicleta', 2820.00, 3077);
  INSERT INTO REPARTIDOR VALUES (1334, 'LIC1334', 'Disponible', 'Moto', 2830.00, 3077);
  INSERT INTO REPARTIDOR VALUES (1335, 'LIC1335', 'Ocupado', 'Auto', 2840.00, 3077);
  INSERT INTO REPARTIDOR VALUES (1336, NULL, 'Fuera de servicio', 'Bicicleta', 2850.00, 3078);
  INSERT INTO REPARTIDOR VALUES (1337, 'LIC1337', 'Disponible', 'Moto', 2860.00, 3078);
  INSERT INTO REPARTIDOR VALUES (1338, 'LIC1338', 'Ocupado', 'Auto', 2870.00, 3078);
  INSERT INTO REPARTIDOR VALUES (1339, NULL, 'Fuera de servicio', 'Bicicleta', 2880.00, 3078);
  INSERT INTO REPARTIDOR VALUES (1340, 'LIC1340', 'Disponible', 'Moto', 2890.00, 3078);
  INSERT INTO REPARTIDOR VALUES (1341, 'LIC1341', 'Ocupado', 'Auto', 2900.00, 3079);
  INSERT INTO REPARTIDOR VALUES (1342, NULL, 'Fuera de servicio', 'Bicicleta', 2910.00, 3079);
  INSERT INTO REPARTIDOR VALUES (1343, 'LIC1343', 'Disponible', 'Moto', 2920.00, 3079);
  INSERT INTO REPARTIDOR VALUES (1344, 'LIC1344', 'Ocupado', 'Auto', 2930.00, 3079);
  INSERT INTO REPARTIDOR VALUES (1345, NULL, 'Fuera de servicio', 'Bicicleta', 2940.00, 3079);
  INSERT INTO REPARTIDOR VALUES (1346, 'LIC1346', 'Disponible', 'Moto', 2950.00, 3080);
  INSERT INTO REPARTIDOR VALUES (1347, 'LIC1347', 'Ocupado', 'Auto', 2960.00, 3080);
  INSERT INTO REPARTIDOR VALUES (1348, NULL, 'Fuera de servicio', 'Bicicleta', 2970.00, 3080);
  INSERT INTO REPARTIDOR VALUES (1349, 'LIC1349', 'Disponible', 'Moto', 2980.00, 3080);
  INSERT INTO REPARTIDOR VALUES (1350, 'LIC1350', 'Ocupado', 'Auto', 2990.00, 3080);
  INSERT INTO REPARTIDOR VALUES (1351, NULL, 'Fuera de servicio', 'Bicicleta', 3000.00, 3081);
  INSERT INTO REPARTIDOR VALUES (1352, 'LIC1352', 'Disponible', 'Moto', 3010.00, 3081);
  INSERT INTO REPARTIDOR VALUES (1353, 'LIC1353', 'Ocupado', 'Auto', 3020.00, 3081);
  INSERT INTO REPARTIDOR VALUES (1354, NULL, 'Fuera de servicio', 'Bicicleta', 3030.00, 3081);
  INSERT INTO REPARTIDOR VALUES (1355, 'LIC1355', 'Disponible', 'Moto', 3040.00, 3081);
  INSERT INTO REPARTIDOR VALUES (1356, 'LIC1356', 'Ocupado', 'Auto', 3050.00, 3082);
  INSERT INTO REPARTIDOR VALUES (1357, NULL, 'Fuera de servicio', 'Bicicleta', 3060.00, 3082);
  INSERT INTO REPARTIDOR VALUES (1358, 'LIC1358', 'Disponible', 'Moto', 3070.00, 3082);
  INSERT INTO REPARTIDOR VALUES (1359, 'LIC1359', 'Ocupado', 'Auto', 3080.00, 3082);
  INSERT INTO REPARTIDOR VALUES (1360, NULL, 'Fuera de servicio', 'Bicicleta', 3090.00, 3082);
  INSERT INTO REPARTIDOR VALUES (1361, 'LIC1361', 'Disponible', 'Moto', 3100.00, 3083);
  INSERT INTO REPARTIDOR VALUES (1362, 'LIC1362', 'Ocupado', 'Auto', 3110.00, 3083);
  INSERT INTO REPARTIDOR VALUES (1363, NULL, 'Fuera de servicio', 'Bicicleta', 3120.00, 3083);
  INSERT INTO REPARTIDOR VALUES (1364, 'LIC1364', 'Disponible', 'Moto', 3130.00, 3083);
  INSERT INTO REPARTIDOR VALUES (1365, 'LIC1365', 'Ocupado', 'Auto', 3140.00, 3083);
  INSERT INTO REPARTIDOR VALUES (1366, NULL, 'Fuera de servicio', 'Bicicleta', 3150.00, 3084);
  INSERT INTO REPARTIDOR VALUES (1367, 'LIC1367', 'Disponible', 'Moto', 3160.00, 3084);
  INSERT INTO REPARTIDOR VALUES (1368, 'LIC1368', 'Ocupado', 'Auto', 3170.00, 3084);
  INSERT INTO REPARTIDOR VALUES (1369, NULL, 'Fuera de servicio', 'Bicicleta', 3180.00, 3084);
  INSERT INTO REPARTIDOR VALUES (1370, 'LIC1370', 'Disponible', 'Moto', 3190.00, 3084);
  INSERT INTO REPARTIDOR VALUES (1371, 'LIC1371', 'Ocupado', 'Auto', 3200.00, 3085);
  INSERT INTO REPARTIDOR VALUES (1372, NULL, 'Fuera de servicio', 'Bicicleta', 3210.00, 3085);
  INSERT INTO REPARTIDOR VALUES (1373, 'LIC1373', 'Disponible', 'Moto', 3220.00, 3085);
  INSERT INTO REPARTIDOR VALUES (1374, 'LIC1374', 'Ocupado', 'Auto', 3230.00, 3085);
  INSERT INTO REPARTIDOR VALUES (1375, NULL, 'Fuera de servicio', 'Bicicleta', 3240.00, 3085);
  INSERT INTO REPARTIDOR VALUES (1376, 'LIC1376', 'Disponible', 'Moto', 3250.00, 3086);
  INSERT INTO REPARTIDOR VALUES (1377, 'LIC1377', 'Ocupado', 'Auto', 3260.00, 3086);
  INSERT INTO REPARTIDOR VALUES (1378, NULL, 'Fuera de servicio', 'Bicicleta', 3270.00, 3086);
  INSERT INTO REPARTIDOR VALUES (1379, 'LIC1379', 'Disponible', 'Moto', 3280.00, 3086);
  INSERT INTO REPARTIDOR VALUES (1380, 'LIC1380', 'Ocupado', 'Auto', 3290.00, 3086);
  INSERT INTO REPARTIDOR VALUES (1381, NULL, 'Fuera de servicio', 'Bicicleta', 3300.00, 3087);
  INSERT INTO REPARTIDOR VALUES (1382, 'LIC1382', 'Disponible', 'Moto', 3310.00, 3087);
  INSERT INTO REPARTIDOR VALUES (1383, 'LIC1383', 'Ocupado', 'Auto', 3320.00, 3087);
  INSERT INTO REPARTIDOR VALUES (1384, NULL, 'Fuera de servicio', 'Bicicleta', 3330.00, 3087);
  INSERT INTO REPARTIDOR VALUES (1385, 'LIC1385', 'Disponible', 'Moto', 3340.00, 3087);
  INSERT INTO REPARTIDOR VALUES (1386, 'LIC1386', 'Ocupado', 'Auto', 3350.00, 3088);
  INSERT INTO REPARTIDOR VALUES (1387, NULL, 'Fuera de servicio', 'Bicicleta', 3360.00, 3088);
  INSERT INTO REPARTIDOR VALUES (1388, 'LIC1388', 'Disponible', 'Moto', 3370.00, 3088);
  INSERT INTO REPARTIDOR VALUES (1389, 'LIC1389', 'Ocupado', 'Auto', 3380.00, 3088);
  INSERT INTO REPARTIDOR VALUES (1390, NULL, 'Fuera de servicio', 'Bicicleta', 3390.00, 3088);
  INSERT INTO REPARTIDOR VALUES (1391, 'LIC1391', 'Disponible', 'Moto', 3400.00, 3089);
  INSERT INTO REPARTIDOR VALUES (1392, 'LIC1392', 'Ocupado', 'Auto', 3410.00, 3089);
  INSERT INTO REPARTIDOR VALUES (1393, NULL, 'Fuera de servicio', 'Bicicleta', 3420.00, 3089);
  INSERT INTO REPARTIDOR VALUES (1394, 'LIC1394', 'Disponible', 'Moto', 3430.00, 3089);
  INSERT INTO REPARTIDOR VALUES (1395, 'LIC1395', 'Ocupado', 'Auto', 3440.00, 3089);
  INSERT INTO REPARTIDOR VALUES (1396, NULL, 'Fuera de servicio', 'Bicicleta', 3450.00, 3090);
  INSERT INTO REPARTIDOR VALUES (1397, 'LIC1397', 'Disponible', 'Moto', 3460.00, 3090);
  INSERT INTO REPARTIDOR VALUES (1398, 'LIC1398', 'Ocupado', 'Auto', 3470.00, 3090);
  INSERT INTO REPARTIDOR VALUES (1399, NULL, 'Fuera de servicio', 'Bicicleta', 3480.00, 3090);
  INSERT INTO REPARTIDOR VALUES (1400, 'LIC1400', 'Disponible', 'Moto', 3490.00, 3090);
  COMMIT;
END;
 

BEGIN
  INSERT INTO REPARTIDOR VALUES (1401, 'LIC1401', 'Ocupado', 'Auto', 1500.00, 3091);
  INSERT INTO REPARTIDOR VALUES (1402, NULL, 'Fuera de servicio', 'Bicicleta', 1510.00, 3091);
  INSERT INTO REPARTIDOR VALUES (1403, 'LIC1403', 'Disponible', 'Moto', 1520.00, 3091);
  INSERT INTO REPARTIDOR VALUES (1404, 'LIC1404', 'Ocupado', 'Auto', 1530.00, 3091);
  INSERT INTO REPARTIDOR VALUES (1405, NULL, 'Fuera de servicio', 'Bicicleta', 1540.00, 3091);
  INSERT INTO REPARTIDOR VALUES (1406, 'LIC1406', 'Disponible', 'Moto', 1550.00, 3092);
  INSERT INTO REPARTIDOR VALUES (1407, 'LIC1407', 'Ocupado', 'Auto', 1560.00, 3092);
  INSERT INTO REPARTIDOR VALUES (1408, NULL, 'Fuera de servicio', 'Bicicleta', 1570.00, 3092);
  INSERT INTO REPARTIDOR VALUES (1409, 'LIC1409', 'Disponible', 'Moto', 1580.00, 3092);
  INSERT INTO REPARTIDOR VALUES (1410, 'LIC1410', 'Ocupado', 'Auto', 1590.00, 3092);
  INSERT INTO REPARTIDOR VALUES (1411, NULL, 'Fuera de servicio', 'Bicicleta', 1600.00, 3093);
  INSERT INTO REPARTIDOR VALUES (1412, 'LIC1412', 'Disponible', 'Moto', 1610.00, 3093);
  INSERT INTO REPARTIDOR VALUES (1413, 'LIC1413', 'Ocupado', 'Auto', 1620.00, 3093);
  INSERT INTO REPARTIDOR VALUES (1414, NULL, 'Fuera de servicio', 'Bicicleta', 1630.00, 3093);
  INSERT INTO REPARTIDOR VALUES (1415, 'LIC1415', 'Disponible', 'Moto', 1640.00, 3093);
  INSERT INTO REPARTIDOR VALUES (1416, 'LIC1416', 'Ocupado', 'Auto', 1650.00, 3094);
  INSERT INTO REPARTIDOR VALUES (1417, NULL, 'Fuera de servicio', 'Bicicleta', 1660.00, 3094);
  INSERT INTO REPARTIDOR VALUES (1418, 'LIC1418', 'Disponible', 'Moto', 1670.00, 3094);
  INSERT INTO REPARTIDOR VALUES (1419, 'LIC1419', 'Ocupado', 'Auto', 1680.00, 3094);
  INSERT INTO REPARTIDOR VALUES (1420, NULL, 'Fuera de servicio', 'Bicicleta', 1690.00, 3094);
  INSERT INTO REPARTIDOR VALUES (1421, 'LIC1421', 'Disponible', 'Moto', 1700.00, 3095);
  INSERT INTO REPARTIDOR VALUES (1422, 'LIC1422', 'Ocupado', 'Auto', 1710.00, 3095);
  INSERT INTO REPARTIDOR VALUES (1423, NULL, 'Fuera de servicio', 'Bicicleta', 1720.00, 3095);
  INSERT INTO REPARTIDOR VALUES (1424, 'LIC1424', 'Disponible', 'Moto', 1730.00, 3095);
  INSERT INTO REPARTIDOR VALUES (1425, 'LIC1425', 'Ocupado', 'Auto', 1740.00, 3095);
  INSERT INTO REPARTIDOR VALUES (1426, NULL, 'Fuera de servicio', 'Bicicleta', 1750.00, 3096);
  INSERT INTO REPARTIDOR VALUES (1427, 'LIC1427', 'Disponible', 'Moto', 1760.00, 3096);
  INSERT INTO REPARTIDOR VALUES (1428, 'LIC1428', 'Ocupado', 'Auto', 1770.00, 3096);
  INSERT INTO REPARTIDOR VALUES (1429, NULL, 'Fuera de servicio', 'Bicicleta', 1780.00, 3096);
  INSERT INTO REPARTIDOR VALUES (1430, 'LIC1430', 'Disponible', 'Moto', 1790.00, 3096);
  INSERT INTO REPARTIDOR VALUES (1431, 'LIC1431', 'Ocupado', 'Auto', 1800.00, 3097);
  INSERT INTO REPARTIDOR VALUES (1432, NULL, 'Fuera de servicio', 'Bicicleta', 1810.00, 3097);
  INSERT INTO REPARTIDOR VALUES (1433, 'LIC1433', 'Disponible', 'Moto', 1820.00, 3097);
  INSERT INTO REPARTIDOR VALUES (1434, 'LIC1434', 'Ocupado', 'Auto', 1830.00, 3097);
  INSERT INTO REPARTIDOR VALUES (1435, NULL, 'Fuera de servicio', 'Bicicleta', 1840.00, 3097);
  INSERT INTO REPARTIDOR VALUES (1436, 'LIC1436', 'Disponible', 'Moto', 1850.00, 3098);
  INSERT INTO REPARTIDOR VALUES (1437, 'LIC1437', 'Ocupado', 'Auto', 1860.00, 3098);
  INSERT INTO REPARTIDOR VALUES (1438, NULL, 'Fuera de servicio', 'Bicicleta', 1870.00, 3098);
  INSERT INTO REPARTIDOR VALUES (1439, 'LIC1439', 'Disponible', 'Moto', 1880.00, 3098);
  INSERT INTO REPARTIDOR VALUES (1440, 'LIC1440', 'Ocupado', 'Auto', 1890.00, 3098);
  INSERT INTO REPARTIDOR VALUES (1441, NULL, 'Fuera de servicio', 'Bicicleta', 1900.00, 3099);
  INSERT INTO REPARTIDOR VALUES (1442, 'LIC1442', 'Disponible', 'Moto', 1910.00, 3099);
  INSERT INTO REPARTIDOR VALUES (1443, 'LIC1443', 'Ocupado', 'Auto', 1920.00, 3099);
  INSERT INTO REPARTIDOR VALUES (1444, NULL, 'Fuera de servicio', 'Bicicleta', 1930.00, 3099);
  INSERT INTO REPARTIDOR VALUES (1445, 'LIC1445', 'Disponible', 'Moto', 1940.00, 3099);
  INSERT INTO REPARTIDOR VALUES (1446, 'LIC1446', 'Ocupado', 'Auto', 1950.00, 3100);
  INSERT INTO REPARTIDOR VALUES (1447, NULL, 'Fuera de servicio', 'Bicicleta', 1960.00, 3100);
  INSERT INTO REPARTIDOR VALUES (1448, 'LIC1448', 'Disponible', 'Moto', 1970.00, 3100);
  INSERT INTO REPARTIDOR VALUES (1449, 'LIC1449', 'Ocupado', 'Auto', 1980.00, 3100);
  INSERT INTO REPARTIDOR VALUES (1450, NULL, 'Fuera de servicio', 'Bicicleta', 1990.00, 3100);
  COMMIT;
END;
 




--CLIENTE

BEGIN
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1351, 1250, TO_DATE('2023-02-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1352, 3420, TO_DATE('2021-11-20', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1353, 890, TO_DATE('2024-01-10', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1354, 2500, TO_DATE('2022-08-05', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1355, 75, TO_DATE('2024-05-18', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1356, 4100, TO_DATE('2020-12-12', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1357, 1850, TO_DATE('2023-09-22', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1358, 360, TO_DATE('2024-02-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1359, 2780, TO_DATE('2021-04-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1360, 520, TO_DATE('2023-12-01', 'YYYY-MM-DD'), 'Activo');

    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1361, 1890, TO_DATE('2022-06-25', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1362, 45, TO_DATE('2024-07-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1363, 3100, TO_DATE('2020-09-30', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1364, 0, TO_DATE('2024-03-15', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1365, 920, TO_DATE('2023-01-07', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1366, 2750, TO_DATE('2021-10-11', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1367, 4800, TO_DATE('2019-12-20', 'YYYY-MM-DD'), 'Activo'); -- Fecha antigua pero valida
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1368, 630, TO_DATE('2024-01-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1369, 1500, TO_DATE('2022-11-02', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1370, 1080, TO_DATE('2023-06-14', 'YYYY-MM-DD'), 'Activo');

    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1371, 3900, TO_DATE('2020-08-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1372, 210, TO_DATE('2024-04-05', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1373, 1670, TO_DATE('2022-02-09', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1374, 2880, TO_DATE('2023-08-21', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1375, 730, TO_DATE('2021-12-13', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1376, 125, TO_DATE('2024-06-30', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1377, 4350, TO_DATE('2021-03-17', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1378, 1950, TO_DATE('2022-09-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1379, 85, TO_DATE('2024-02-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1380, 3020, TO_DATE('2020-11-25', 'YYYY-MM-DD'), 'Activo');

    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1381, 1460, TO_DATE('2023-04-18', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1382, 560, TO_DATE('2021-07-09', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1383, 2100, TO_DATE('2024-01-05', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1384, 90, TO_DATE('2023-10-12', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1385, 3650, TO_DATE('2022-04-30', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1386, 430, TO_DATE('2024-08-22', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1387, 1120, TO_DATE('2020-10-03', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1388, 2570, TO_DATE('2023-11-17', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1389, 690, TO_DATE('2021-05-26', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1390, 1880, TO_DATE('2022-12-08', 'YYYY-MM-DD'), 'Activo');

    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1391, 3240, TO_DATE('2020-06-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1392, 180, TO_DATE('2024-03-21', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1393, 2780, TO_DATE('2022-10-10', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1394, 950, TO_DATE('2023-05-29', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1395, 4120, TO_DATE('2021-09-07', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1396, 60, TO_DATE('2024-07-12', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1397, 150, TO_DATE('2023-01-28', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1398, 2290, TO_DATE('2022-05-04', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1399, 3750, TO_DATE('2020-07-22', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1400, 810, TO_DATE('2024-02-17', 'YYYY-MM-DD'), 'Inactivo');

    COMMIT;
END;
 


BEGIN
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1401, 1630, TO_DATE('2023-08-27', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1402, 40, TO_DATE('2024-05-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1403, 3870, TO_DATE('2021-12-03', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1404, 540, TO_DATE('2022-09-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1405, 2070, TO_DATE('2020-10-31', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1406, 1230, TO_DATE('2024-01-18', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1407, 2980, TO_DATE('2023-04-05', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1408, 690, TO_DATE('2021-06-23', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1409, 45, TO_DATE('2024-08-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1410, 3520, TO_DATE('2022-02-07', 'YYYY-MM-DD'), 'Activo');

    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1411, 780, TO_DATE('2020-11-12', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1412, 1920, TO_DATE('2023-09-21', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1413, 560, TO_DATE('2024-03-09', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1414, 1450, TO_DATE('2022-07-27', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1415, 2450, TO_DATE('2021-10-18', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1416, 115, TO_DATE('2024-05-30', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1417, 4120, TO_DATE('2023-01-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1418, 890, TO_DATE('2020-08-25', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1419, 3110, TO_DATE('2022-12-11', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1420, 230, TO_DATE('2023-07-04', 'YYYY-MM-DD'), 'Activo');

    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1421, 1740, TO_DATE('2021-05-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1422, 4850, TO_DATE('2024-02-23', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1423, 680, TO_DATE('2022-04-16', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1424, 2260, TO_DATE('2020-09-08', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1425, 130, TO_DATE('2023-11-25', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1426, 3700, TO_DATE('2021-07-30', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1427, 950, TO_DATE('2024-04-10', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1428, 2840, TO_DATE('2023-06-06', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1429, 1550, TO_DATE('2022-01-29', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1430, 420, TO_DATE('2020-12-16', 'YYYY-MM-DD'), 'Activo');

    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1431, 3380, TO_DATE('2023-03-12', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1432, 75, TO_DATE('2024-07-22', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1433, 820, TO_DATE('2021-09-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1434, 2170, TO_DATE('2022-08-03', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1435, 360, TO_DATE('2020-05-21', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1436, 4030, TO_DATE('2024-01-31', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1437, 1480, TO_DATE('2023-10-08', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1438, 630, TO_DATE('2021-11-27', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1439, 910, TO_DATE('2022-06-14', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1440, 2730, TO_DATE('2024-03-25', 'YYYY-MM-DD'), 'Activo');

    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1441, 1880, TO_DATE('2020-07-07', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1442, 50, TO_DATE('2023-12-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1443, 3290, TO_DATE('2021-04-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1444, 710, TO_DATE('2022-10-02', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1445, 260, TO_DATE('2024-06-12', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1446, 1950, TO_DATE('2023-02-20', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1447, 4200, TO_DATE('2020-09-13', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1448, 580, TO_DATE('2021-08-05', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1449, 1430, TO_DATE('2024-05-27', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1450, 3120, TO_DATE('2022-11-09', 'YYYY-MM-DD'), 'Activo');

    COMMIT;
END;
 


BEGIN
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1451, 850, TO_DATE('2023-07-17', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1452, 2850, TO_DATE('2021-12-24', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1453, 120, TO_DATE('2024-04-03', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1454, 3620, TO_DATE('2022-03-15', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1455, 790, TO_DATE('2020-06-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1456, 440, TO_DATE('2023-11-05', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1457, 2050, TO_DATE('2021-09-01', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1458, 3780, TO_DATE('2024-02-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1459, 60, TO_DATE('2022-07-29', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1460, 1310, TO_DATE('2020-10-17', 'YYYY-MM-DD'), 'Activo');

    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1461, 2970, TO_DATE('2023-05-09', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1462, 520, TO_DATE('2024-08-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1463, 1850, TO_DATE('2021-11-10', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1464, 245, TO_DATE('2022-04-26', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1465, 4100, TO_DATE('2020-12-01', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1466, 940, TO_DATE('2023-09-14', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1467, 280, TO_DATE('2024-01-07', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1468, 3520, TO_DATE('2021-05-23', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1469, 675, TO_DATE('2022-09-30', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1470, 1680, TO_DATE('2023-02-08', 'YYYY-MM-DD'), 'Activo');

    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1471, 2390, TO_DATE('2020-08-11', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1472, 80, TO_DATE('2024-06-25', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1473, 3210, TO_DATE('2022-12-17', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1474, 460, TO_DATE('2021-07-14', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1475, 1940, TO_DATE('2024-03-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1476, 500, TO_DATE('2023-10-22', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1477, 2860, TO_DATE('2021-02-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1478, 730, TO_DATE('2020-04-13', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1479, 160, TO_DATE('2022-06-05', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1480, 3770, TO_DATE('2024-07-16', 'YYYY-MM-DD'), 'Inactivo');

    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1481, 1120, TO_DATE('2023-04-20', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1482, 55, TO_DATE('2021-08-27', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1483, 2490, TO_DATE('2020-10-09', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1484, 870, TO_DATE('2022-03-03', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1485, 3350, TO_DATE('2024-01-26', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1486, 410, TO_DATE('2023-11-30', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1487, 1630, TO_DATE('2021-12-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1488, 2980, TO_DATE('2022-08-22', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1489, 720, TO_DATE('2024-05-07', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1490, 140, TO_DATE('2020-06-18', 'YYYY-MM-DD'), 'Activo');

    COMMIT;
END;
 



BEGIN
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1491, 2280, TO_DATE('2023-07-03', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1492, 580, TO_DATE('2021-09-11', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1493, 3960, TO_DATE('2022-04-08', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1494, 320, TO_DATE('2024-07-29', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1495, 1750, TO_DATE('2020-11-02', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1496, 2650, TO_DATE('2021-05-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1497, 90, TO_DATE('2023-12-10', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1498, 3410, TO_DATE('2024-02-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1499, 780, TO_DATE('2022-10-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1500, 2170, TO_DATE('2023-05-19', 'YYYY-MM-DD'), 'Suspendido');

    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1501, 460, TO_DATE('2020-09-26', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1502, 3890, TO_DATE('2024-03-11', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1503, 1420, TO_DATE('2022-07-20', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1504, 630, TO_DATE('2021-11-29', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1505, 2750, TO_DATE('2023-01-17', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1506, 105, TO_DATE('2024-06-04', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1507, 3540, TO_DATE('2020-08-23', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1508, 820, TO_DATE('2022-12-12', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1509, 1910, TO_DATE('2023-09-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1510, 530, TO_DATE('2021-06-21', 'YYYY-MM-DD'), 'Activo');

    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1511, 3070, TO_DATE('2024-04-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1512, 175, TO_DATE('2022-09-05', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1513, 2530, TO_DATE('2020-12-24', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1514, 690, TO_DATE('2023-03-31', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1515, 1400, TO_DATE('2021-10-09', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1516, 4050, TO_DATE('2024-01-20', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1517, 370, TO_DATE('2022-05-18', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1518, 2880, TO_DATE('2023-11-12', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1519, 950, TO_DATE('2020-07-06', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1520, 2150, TO_DATE('2024-08-02', 'YYYY-MM-DD'), 'Activo');
	COMMIT;
END;
 
BEGIN
    -- Clientes 1521-1530
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1521, 1250, TO_DATE('2023-02-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1522, 3420, TO_DATE('2021-11-20', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1523, 890, TO_DATE('2024-01-10', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1524, 2500, TO_DATE('2022-08-05', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1525, 75, TO_DATE('2024-05-18', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1526, 4100, TO_DATE('2020-12-12', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1527, 1850, TO_DATE('2023-09-22', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1528, 360, TO_DATE('2024-02-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1529, 2780, TO_DATE('2021-04-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1530, 520, TO_DATE('2023-12-01', 'YYYY-MM-DD'), 'Activo');

    -- Clientes 1531-1540
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1531, 1890, TO_DATE('2022-06-25', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1532, 45, TO_DATE('2024-07-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1533, 3100, TO_DATE('2020-09-30', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1534, 0, TO_DATE('2024-03-15', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1535, 920, TO_DATE('2023-01-07', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1536, 2750, TO_DATE('2021-10-11', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1537, 4800, TO_DATE('2019-12-20', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1538, 630, TO_DATE('2024-01-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1539, 1500, TO_DATE('2022-11-02', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1540, 1080, TO_DATE('2023-06-14', 'YYYY-MM-DD'), 'Activo');

    -- Clientes 1541-1550
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1541, 3900, TO_DATE('2020-08-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1542, 210, TO_DATE('2024-04-05', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1543, 1670, TO_DATE('2022-02-09', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1544, 2880, TO_DATE('2023-08-21', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1545, 730, TO_DATE('2021-12-13', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1546, 125, TO_DATE('2024-06-30', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1547, 4350, TO_DATE('2021-03-17', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1548, 1950, TO_DATE('2022-09-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1549, 85, TO_DATE('2024-02-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1550, 3020, TO_DATE('2020-11-25', 'YYYY-MM-DD'), 'Activo');

    -- Clientes 1551-1560
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1551, 1460, TO_DATE('2023-04-18', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1552, 560, TO_DATE('2021-07-09', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1553, 2100, TO_DATE('2024-01-05', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1554, 90, TO_DATE('2023-10-12', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1555, 3650, TO_DATE('2022-04-30', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1556, 430, TO_DATE('2024-08-22', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1557, 1120, TO_DATE('2020-10-03', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1558, 2570, TO_DATE('2023-11-17', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1559, 690, TO_DATE('2021-05-26', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1560, 1880, TO_DATE('2022-12-08', 'YYYY-MM-DD'), 'Activo');

    -- Clientes 1561-1570
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1561, 3240, TO_DATE('2020-06-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1562, 180, TO_DATE('2024-03-21', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1563, 2780, TO_DATE('2022-10-10', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1564, 950, TO_DATE('2023-05-29', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1565, 4120, TO_DATE('2021-09-07', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1566, 60, TO_DATE('2024-07-12', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1567, 150, TO_DATE('2023-01-28', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1568, 2290, TO_DATE('2022-05-04', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1569, 3750, TO_DATE('2020-07-22', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1570, 810, TO_DATE('2024-02-17', 'YYYY-MM-DD'), 'Activo');

    -- Clientes 1571-1580
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1571, 1630, TO_DATE('2023-08-27', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1572, 40, TO_DATE('2024-05-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1573, 3870, TO_DATE('2021-12-03', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1574, 540, TO_DATE('2022-09-19', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1575, 2070, TO_DATE('2020-10-31', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1576, 1230, TO_DATE('2024-01-18', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1577, 2980, TO_DATE('2023-04-05', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1578, 690, TO_DATE('2021-06-23', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1579, 45, TO_DATE('2024-08-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1580, 3520, TO_DATE('2022-02-07', 'YYYY-MM-DD'), 'Activo');

    -- Clientes 1581-1590
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1581, 780, TO_DATE('2020-11-12', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1582, 1920, TO_DATE('2023-09-21', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1583, 5600, TO_DATE('2024-03-09', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1584, 1450, TO_DATE('2022-07-27', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1585, 2450, TO_DATE('2021-10-18', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1586, 115, TO_DATE('2024-05-30', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1587, 4120, TO_DATE('2023-01-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1588, 890, TO_DATE('2020-08-25', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1589, 3110, TO_DATE('2022-12-11', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1590, 230, TO_DATE('2023-07-04', 'YYYY-MM-DD'), 'Activo');

    -- Clientes 1591-1600
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1591, 1740, TO_DATE('2021-05-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1592, 4850, TO_DATE('2024-02-23', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1593, 680, TO_DATE('2022-04-16', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1594, 2260, TO_DATE('2020-09-08', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1595, 130, TO_DATE('2023-11-25', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1596, 3700, TO_DATE('2021-07-30', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1597, 950, TO_DATE('2024-04-10', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1598, 2840, TO_DATE('2023-06-06', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1599, 1550, TO_DATE('2022-01-29', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1600, 420, TO_DATE('2020-12-16', 'YYYY-MM-DD'), 'Activo');

    -- Clientes 1601-1610
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1601, 3380, TO_DATE('2023-03-12', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1602, 75, TO_DATE('2024-07-22', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1603, 820, TO_DATE('2021-09-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1604, 2170, TO_DATE('2022-08-03', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1605, 360, TO_DATE('2020-05-21', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1606, 4030, TO_DATE('2024-01-31', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1607, 1480, TO_DATE('2023-10-08', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1608, 630, TO_DATE('2021-11-27', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1609, 910, TO_DATE('2022-06-14', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1610, 2730, TO_DATE('2024-03-25', 'YYYY-MM-DD'), 'Activo');

    -- Clientes 1611-1620
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1611, 1880, TO_DATE('2020-07-07', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1612, 50, TO_DATE('2023-12-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1613, 3290, TO_DATE('2021-04-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1614, 710, TO_DATE('2022-10-02', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1615, 260, TO_DATE('2024-06-12', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1616, 1950, TO_DATE('2023-02-20', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1617, 4200, TO_DATE('2020-09-13', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1618, 580, TO_DATE('2021-08-05', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1619, 1430, TO_DATE('2024-05-27', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1620, 3120, TO_DATE('2022-11-09', 'YYYY-MM-DD'), 'Activo');

    COMMIT;
END;
 



BEGIN
    -- Clientes 1621-1630
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1621, 850, TO_DATE('2023-07-17', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1622, 2850, TO_DATE('2021-12-24', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1623, 120, TO_DATE('2024-04-03', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1624, 3620, TO_DATE('2022-03-15', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1625, 790, TO_DATE('2020-06-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1626, 440, TO_DATE('2023-11-05', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1627, 2050, TO_DATE('2021-09-01', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1628, 3780, TO_DATE('2024-02-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1629, 60, TO_DATE('2022-07-29', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1630, 1310, TO_DATE('2020-10-17', 'YYYY-MM-DD'), 'Activo');

    -- Clientes 1631-1640
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1631, 2970, TO_DATE('2023-05-09', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1632, 520, TO_DATE('2024-08-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1633, 1850, TO_DATE('2021-11-10', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1634, 245, TO_DATE('2022-04-26', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1635, 4100, TO_DATE('2020-12-01', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1636, 940, TO_DATE('2023-09-14', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1637, 280, TO_DATE('2024-01-07', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1638, 3520, TO_DATE('2021-05-23', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1639, 675, TO_DATE('2022-09-30', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1640, 1680, TO_DATE('2023-02-08', 'YYYY-MM-DD'), 'Activo');

    -- Clientes 1641-1650
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1641, 2390, TO_DATE('2020-08-11', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1642, 80, TO_DATE('2024-06-25', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1643, 3210, TO_DATE('2022-12-17', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1644, 460, TO_DATE('2021-07-14', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1645, 1940, TO_DATE('2024-03-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1646, 500, TO_DATE('2023-10-22', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1647, 2860, TO_DATE('2021-02-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1648, 730, TO_DATE('2020-04-13', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1649, 160, TO_DATE('2022-06-05', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1650, 3770, TO_DATE('2024-07-16', 'YYYY-MM-DD'), 'Inactivo');

    -- Clientes 1651-1660
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1651, 1120, TO_DATE('2023-04-20', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1652, 55, TO_DATE('2021-08-27', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1653, 2490, TO_DATE('2020-10-09', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1654, 870, TO_DATE('2022-03-03', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1655, 3350, TO_DATE('2024-01-26', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1656, 410, TO_DATE('2023-11-30', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1657, 1630, TO_DATE('2021-12-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1658, 2980, TO_DATE('2022-08-22', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1659, 720, TO_DATE('2024-05-07', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1660, 140, TO_DATE('2020-06-18', 'YYYY-MM-DD'), 'Activo');

    -- Clientes 1661-1670
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1661, 2280, TO_DATE('2023-07-03', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1662, 580, TO_DATE('2021-09-11', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1663, 3960, TO_DATE('2022-04-08', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1664, 320, TO_DATE('2024-07-29', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1665, 1750, TO_DATE('2020-11-02', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1666, 2650, TO_DATE('2021-05-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1667, 90, TO_DATE('2023-12-10', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1668, 3410, TO_DATE('2024-02-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1669, 780, TO_DATE('2022-10-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1670, 2170, TO_DATE('2023-05-19', 'YYYY-MM-DD'), 'Suspendido');

    -- Clientes 1671-1680
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1671, 460, TO_DATE('2020-09-26', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1672, 3890, TO_DATE('2024-03-11', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1673, 1420, TO_DATE('2022-07-20', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1674, 630, TO_DATE('2021-11-29', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1675, 2750, TO_DATE('2023-01-17', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1676, 105, TO_DATE('2024-06-04', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1677, 3540, TO_DATE('2020-08-23', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1678, 820, TO_DATE('2022-12-12', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1679, 1910, TO_DATE('2023-09-28', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1680, 530, TO_DATE('2021-06-21', 'YYYY-MM-DD'), 'Activo');

    -- Clientes 1681-1690
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1681, 3070, TO_DATE('2024-04-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1682, 175, TO_DATE('2022-09-05', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1683, 2530, TO_DATE('2020-12-24', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1684, 690, TO_DATE('2023-03-31', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1685, 1400, TO_DATE('2021-10-09', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1686, 4050, TO_DATE('2024-01-20', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1687, 370, TO_DATE('2022-05-18', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1688, 2880, TO_DATE('2023-11-12', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1689, 950, TO_DATE('2020-07-06', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1690, 2150, TO_DATE('2024-08-02', 'YYYY-MM-DD'), 'Activo');

    -- Clientes 1691-1700
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1691, 680, TO_DATE('2023-03-18', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1692, 2920, TO_DATE('2021-11-02', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1693, 1050, TO_DATE('2024-05-23', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1694, 3780, TO_DATE('2022-09-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1695, 320, TO_DATE('2020-12-28', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1696, 1850, TO_DATE('2023-06-09', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1697, 590, TO_DATE('2021-08-17', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1698, 4230, TO_DATE('2024-01-04', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1699, 1120, TO_DATE('2022-04-22', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1700, 2670, TO_DATE('2023-10-31', 'YYYY-MM-DD'), 'Inactivo');

    -- Clientes 1701-1710
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1701, 830, TO_DATE('2020-07-24', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1702, 3540, TO_DATE('2024-03-16', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1703, 210, TO_DATE('2022-11-28', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1704, 1680, TO_DATE('2021-06-05', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1705, 2930, TO_DATE('2023-09-13', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1706, 75, TO_DATE('2024-07-08', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1707, 1480, TO_DATE('2020-10-29', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1708, 4120, TO_DATE('2022-05-12', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1709, 620, TO_DATE('2023-12-03', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1710, 2360, TO_DATE('2021-09-25', 'YYYY-MM-DD'), 'Suspendido');

    -- Clientes 1711-1720
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1711, 980, TO_DATE('2024-02-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1712, 3150, TO_DATE('2020-08-07', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1713, 170, TO_DATE('2023-06-18', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1714, 3880, TO_DATE('2022-01-26', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1715, 540, TO_DATE('2021-11-19', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1716, 2740, TO_DATE('2024-04-29', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1717, 130, TO_DATE('2023-08-15', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1718, 3590, TO_DATE('2020-12-09', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1719, 810, TO_DATE('2022-07-24', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1720, 2020, TO_DATE('2023-05-03', 'YYYY-MM-DD'), 'Activo');

    COMMIT;
END;
 



BEGIN
    -- Clientes 1721-1730
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1721, 460, TO_DATE('2021-03-12', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1722, 3320, TO_DATE('2024-01-21', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1723, 750, TO_DATE('2022-08-08', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1724, 2680, TO_DATE('2020-11-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1725, 95, TO_DATE('2023-09-27', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1726, 4010, TO_DATE('2024-06-06', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1727, 1370, TO_DATE('2021-12-18', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1728, 580, TO_DATE('2022-04-14', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1729, 2250, TO_DATE('2023-10-10', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1730, 310, TO_DATE('2020-09-02', 'YYYY-MM-DD'), 'Inactivo');

    -- Clientes 1731-1740
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1731, 3860, TO_DATE('2024-02-09', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1732, 1240, TO_DATE('2022-11-16', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1733, 65, TO_DATE('2021-07-07', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1734, 2980, TO_DATE('2023-04-26', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1735, 760, TO_DATE('2020-05-31', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1736, 2140, TO_DATE('2024-08-11', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1737, 480, TO_DATE('2022-12-29', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1738, 3560, TO_DATE('2021-10-03', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1739, 920, TO_DATE('2023-07-21', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1740, 1870, TO_DATE('2020-06-26', 'YYYY-MM-DD'), 'Suspendido');

    -- Clientes 1741-1750
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1741, 540, TO_DATE('2024-03-02', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1742, 3210, TO_DATE('2022-09-09', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1743, 110, TO_DATE('2021-05-01', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1744, 2740, TO_DATE('2023-11-26', 'YYYY-MM-DD'), 'Inactivo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1745, 690, TO_DATE('2020-08-15', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1746, 4080, TO_DATE('2024-05-20', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1747, 1580, TO_DATE('2022-06-27', 'YYYY-MM-DD'), 'Suspendido');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1748, 420, TO_DATE('2021-02-13', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1749, 3480, TO_DATE('2023-09-01', 'YYYY-MM-DD'), 'Activo');
    INSERT INTO CLIENTE (id_persona, puntos_fidelidad, fecha_registro, estado_cliente)
    VALUES (1750, 1320, TO_DATE('2024-01-17', 'YYYY-MM-DD'), 'Activo');

    COMMIT;
END;
 




--DIRECCION

BEGIN
  -- 80% (1 sola dirección)
  INSERT INTO DIRECCION VALUES (1000, 'Plan 3000', 'Av. Principal', '58', 1351);
  INSERT INTO DIRECCION VALUES (1001, 'Queru Queru', 'Av. Melchor Urquidi', '61', 1352);
  INSERT INTO DIRECCION VALUES (1002, 'Cala Cala', 'Av. Libertador', '64', 1353);
  INSERT INTO DIRECCION VALUES (1003, 'Centro', 'Calle Ayacucho', '67', 1354);
  INSERT INTO DIRECCION VALUES (1004, 'Achumani', 'Calle 22', '70', 1355);
  INSERT INTO DIRECCION VALUES (1005, 'Irpavi', 'Calle 10', '73', 1356);
  INSERT INTO DIRECCION VALUES (1006, 'Cota Cota', 'Calle 35', '76', 1357);
  INSERT INTO DIRECCION VALUES (1007, 'Sopocachi', 'Av. Ecuador', '79', 1358);
  INSERT INTO DIRECCION VALUES (1008, 'Miraflores', 'Av. Busch', '82', 1359);
  INSERT INTO DIRECCION VALUES (1009, 'Obrajes', 'Calle 16', '85', 1360);
  INSERT INTO DIRECCION VALUES (1010, 'Calacoto', 'Calle 21', '88', 1361);
  INSERT INTO DIRECCION VALUES (1011, 'San Miguel', 'Av. Montenegro', '91', 1362);
  INSERT INTO DIRECCION VALUES (1012, 'Equipetrol', 'Av. San Martín', '94', 1363);
  INSERT INTO DIRECCION VALUES (1013, 'Urbari', 'Calle 3', '97', 1364);
  INSERT INTO DIRECCION VALUES (1014, 'Plan 3000', 'Av. Principal', '100', 1365);
  INSERT INTO DIRECCION VALUES (1015, 'Queru Queru', 'Av. Melchor Urquidi', '103', 1366);
  INSERT INTO DIRECCION VALUES (1016, 'Cala Cala', 'Av. Libertador', '106', 1367);
  INSERT INTO DIRECCION VALUES (1017, 'Centro', 'Calle Ayacucho', '109', 1368);
  INSERT INTO DIRECCION VALUES (1018, 'Achumani', 'Calle 22', '112', 1369);
  INSERT INTO DIRECCION VALUES (1019, 'Irpavi', 'Calle 10', '115', 1370);
  INSERT INTO DIRECCION VALUES (1020, 'Cota Cota', 'Calle 35', '118', 1371);
  INSERT INTO DIRECCION VALUES (1021, 'Sopocachi', 'Av. Ecuador', '121', 1372);
  INSERT INTO DIRECCION VALUES (1022, 'Miraflores', 'Av. Busch', '124', 1373);
  INSERT INTO DIRECCION VALUES (1023, 'Obrajes', 'Calle 16', '127', 1374);
  INSERT INTO DIRECCION VALUES (1024, 'Calacoto', 'Calle 21', '130', 1375);
  INSERT INTO DIRECCION VALUES (1025, 'San Miguel', 'Av. Montenegro', '133', 1376);
  INSERT INTO DIRECCION VALUES (1026, 'Equipetrol', 'Av. San Martín', '136', 1377);
  INSERT INTO DIRECCION VALUES (1027, 'Urbari', 'Calle 3', '139', 1378);
  INSERT INTO DIRECCION VALUES (1028, 'Plan 3000', 'Av. Principal', '142', 1379);
  INSERT INTO DIRECCION VALUES (1029, 'Queru Queru', 'Av. Melchor Urquidi', '145', 1380);
  INSERT INTO DIRECCION VALUES (1030, 'Cala Cala', 'Av. Libertador', '148', 1381);
  INSERT INTO DIRECCION VALUES (1031, 'Centro', 'Calle Ayacucho', '151', 1382);
  INSERT INTO DIRECCION VALUES (1032, 'Achumani', 'Calle 22', '154', 1383);
  INSERT INTO DIRECCION VALUES (1033, 'Irpavi', 'Calle 10', '157', 1384);
  INSERT INTO DIRECCION VALUES (1034, 'Cota Cota', 'Calle 35', '160', 1385);
  INSERT INTO DIRECCION VALUES (1035, 'Sopocachi', 'Av. Ecuador', '163', 1386);
  INSERT INTO DIRECCION VALUES (1036, 'Miraflores', 'Av. Busch', '166', 1387);
  INSERT INTO DIRECCION VALUES (1037, 'Obrajes', 'Calle 16', '169', 1388);
  INSERT INTO DIRECCION VALUES (1038, 'Calacoto', 'Calle 21', '172', 1389);
  INSERT INTO DIRECCION VALUES (1039, 'San Miguel', 'Av. Montenegro', '175', 1390);
  INSERT INTO DIRECCION VALUES (1040, 'Equipetrol', 'Av. San Martín', '178', 1391);
  INSERT INTO DIRECCION VALUES (1041, 'Urbari', 'Calle 3', '181', 1392);
  INSERT INTO DIRECCION VALUES (1042, 'Plan 3000', 'Av. Principal', '184', 1393);
  INSERT INTO DIRECCION VALUES (1043, 'Queru Queru', 'Av. Melchor Urquidi', '187', 1394);
  INSERT INTO DIRECCION VALUES (1044, 'Cala Cala', 'Av. Libertador', '190', 1395);
  INSERT INTO DIRECCION VALUES (1045, 'Centro', 'Calle Ayacucho', '193', 1396);
  INSERT INTO DIRECCION VALUES (1046, 'Achumani', 'Calle 22', '196', 1397);
  INSERT INTO DIRECCION VALUES (1047, 'Irpavi', 'Calle 10', '199', 1398);
  INSERT INTO DIRECCION VALUES (1048, 'Cota Cota', 'Calle 35', '202', 1399);
  INSERT INTO DIRECCION VALUES (1049, 'Sopocachi', 'Av. Ecuador', '205', 1400);
  INSERT INTO DIRECCION VALUES (1050, 'Miraflores', 'Av. Busch', '208', 1401);
  INSERT INTO DIRECCION VALUES (1051, 'Obrajes', 'Calle 16', '211', 1402);
  INSERT INTO DIRECCION VALUES (1052, 'Calacoto', 'Calle 21', '214', 1403);
  INSERT INTO DIRECCION VALUES (1053, 'San Miguel', 'Av. Montenegro', '217', 1404);
  INSERT INTO DIRECCION VALUES (1054, 'Equipetrol', 'Av. San Martín', '220', 1405);
  INSERT INTO DIRECCION VALUES (1055, 'Urbari', 'Calle 3', '223', 1406);
  INSERT INTO DIRECCION VALUES (1056, 'Plan 3000', 'Av. Principal', '226', 1407);
  INSERT INTO DIRECCION VALUES (1057, 'Queru Queru', 'Av. Melchor Urquidi', '229', 1408);
  INSERT INTO DIRECCION VALUES (1058, 'Cala Cala', 'Av. Libertador', '232', 1409);
  INSERT INTO DIRECCION VALUES (1059, 'Centro', 'Calle Ayacucho', '235', 1410);
  INSERT INTO DIRECCION VALUES (1060, 'Achumani', 'Calle 22', '238', 1411);
  INSERT INTO DIRECCION VALUES (1061, 'Irpavi', 'Calle 10', '241', 1412);
  INSERT INTO DIRECCION VALUES (1062, 'Cota Cota', 'Calle 35', '244', 1413);
  INSERT INTO DIRECCION VALUES (1063, 'Sopocachi', 'Av. Ecuador', '247', 1414);
  INSERT INTO DIRECCION VALUES (1064, 'Miraflores', 'Av. Busch', '250', 1415);
  INSERT INTO DIRECCION VALUES (1065, 'Obrajes', 'Calle 16', '253', 1416);
  INSERT INTO DIRECCION VALUES (1066, 'Calacoto', 'Calle 21', '256', 1417);
  INSERT INTO DIRECCION VALUES (1067, 'San Miguel', 'Av. Montenegro', '259', 1418);
  INSERT INTO DIRECCION VALUES (1068, 'Equipetrol', 'Av. San Martín', '262', 1419);
  INSERT INTO DIRECCION VALUES (1069, 'Urbari', 'Calle 3', '265', 1420);
  INSERT INTO DIRECCION VALUES (1070, 'Plan 3000', 'Av. Principal', '268', 1421);
  INSERT INTO DIRECCION VALUES (1071, 'Queru Queru', 'Av. Melchor Urquidi', '271', 1422);
  INSERT INTO DIRECCION VALUES (1072, 'Cala Cala', 'Av. Libertador', '274', 1423);
  INSERT INTO DIRECCION VALUES (1073, 'Centro', 'Calle Ayacucho', '277', 1424);
  INSERT INTO DIRECCION VALUES (1074, 'Achumani', 'Calle 22', '280', 1425);
  INSERT INTO DIRECCION VALUES (1075, 'Irpavi', 'Calle 10', '283', 1426);
  INSERT INTO DIRECCION VALUES (1076, 'Cota Cota', 'Calle 35', '286', 1427);
  INSERT INTO DIRECCION VALUES (1077, 'Sopocachi', 'Av. Ecuador', '289', 1428);
  INSERT INTO DIRECCION VALUES (1078, 'Miraflores', 'Av. Busch', '292', 1429);
  INSERT INTO DIRECCION VALUES (1079, 'Obrajes', 'Calle 16', '295', 1430);

  -- 15% (2 direcciones: casa y trabajo)
  INSERT INTO DIRECCION VALUES (1080, 'Calacoto', 'Calle 21', '298', 1431);
  INSERT INTO DIRECCION VALUES (1081, 'San Miguel', 'Av. Montenegro', '305', 1431);
  INSERT INTO DIRECCION VALUES (1082, 'San Miguel', 'Av. Montenegro', '301', 1432);
  INSERT INTO DIRECCION VALUES (1083, 'Equipetrol', 'Av. San Martín', '308', 1432);
  INSERT INTO DIRECCION VALUES (1084, 'Equipetrol', 'Av. San Martín', '304', 1433);
  INSERT INTO DIRECCION VALUES (1085, 'Urbari', 'Calle 3', '311', 1433);
  INSERT INTO DIRECCION VALUES (1086, 'Urbari', 'Calle 3', '307', 1434);
  INSERT INTO DIRECCION VALUES (1087, 'Plan 3000', 'Av. Principal', '314', 1434);
  INSERT INTO DIRECCION VALUES (1088, 'Plan 3000', 'Av. Principal', '310', 1435);
  INSERT INTO DIRECCION VALUES (1089, 'Queru Queru', 'Av. Melchor Urquidi', '317', 1435);
  INSERT INTO DIRECCION VALUES (1090, 'Queru Queru', 'Av. Melchor Urquidi', '313', 1436);
  INSERT INTO DIRECCION VALUES (1091, 'Cala Cala', 'Av. Libertador', '320', 1436);
  INSERT INTO DIRECCION VALUES (1092, 'Cala Cala', 'Av. Libertador', '316', 1437);
  INSERT INTO DIRECCION VALUES (1093, 'Centro', 'Calle Ayacucho', '323', 1437);
  INSERT INTO DIRECCION VALUES (1094, 'Centro', 'Calle Ayacucho', '319', 1438);
  INSERT INTO DIRECCION VALUES (1095, 'Achumani', 'Calle 22', '326', 1438);
  INSERT INTO DIRECCION VALUES (1096, 'Achumani', 'Calle 22', '322', 1439);
  INSERT INTO DIRECCION VALUES (1097, 'Irpavi', 'Calle 10', '329', 1439);
  INSERT INTO DIRECCION VALUES (1098, 'Irpavi', 'Calle 10', '325', 1440);
  INSERT INTO DIRECCION VALUES (1099, 'Cota Cota', 'Calle 35', '332', 1440);
  INSERT INTO DIRECCION VALUES (1100, 'Cota Cota', 'Calle 35', '328', 1441);
  INSERT INTO DIRECCION VALUES (1101, 'Sopocachi', 'Av. Ecuador', '335', 1441);
  INSERT INTO DIRECCION VALUES (1102, 'Sopocachi', 'Av. Ecuador', '331', 1442);
  INSERT INTO DIRECCION VALUES (1103, 'Miraflores', 'Av. Busch', '338', 1442);
  INSERT INTO DIRECCION VALUES (1104, 'Miraflores', 'Av. Busch', '334', 1443);
  INSERT INTO DIRECCION VALUES (1105, 'Obrajes', 'Calle 16', '341', 1443);
  INSERT INTO DIRECCION VALUES (1106, 'Obrajes', 'Calle 16', '337', 1444);
  INSERT INTO DIRECCION VALUES (1107, 'Calacoto', 'Calle 21', '344', 1444);
  INSERT INTO DIRECCION VALUES (1108, 'Calacoto', 'Calle 21', '340', 1445);
  INSERT INTO DIRECCION VALUES (1109, 'San Miguel', 'Av. Montenegro', '347', 1445);

  -- 5% (3 direcciones: los jefes)
  INSERT INTO DIRECCION VALUES (1110, 'San Miguel', 'Av. Montenegro', '343', 1446);
  INSERT INTO DIRECCION VALUES (1111, 'Equipetrol', 'Av. San Martín', '350', 1446);
  INSERT INTO DIRECCION VALUES (1112, 'Urbari', 'Calle 3', '357', 1446);
  INSERT INTO DIRECCION VALUES (1113, 'Equipetrol', 'Av. San Martín', '346', 1447);
  INSERT INTO DIRECCION VALUES (1114, 'Urbari', 'Calle 3', '353', 1447);
  INSERT INTO DIRECCION VALUES (1115, 'Plan 3000', 'Av. Principal', '360', 1447);
  INSERT INTO DIRECCION VALUES (1116, 'Urbari', 'Calle 3', '349', 1448);
  INSERT INTO DIRECCION VALUES (1117, 'Plan 3000', 'Av. Principal', '356', 1448);
  INSERT INTO DIRECCION VALUES (1118, 'Queru Queru', 'Av. Melchor Urquidi', '363', 1448);
  INSERT INTO DIRECCION VALUES (1119, 'Plan 3000', 'Av. Principal', '352', 1449);
  INSERT INTO DIRECCION VALUES (1120, 'Queru Queru', 'Av. Melchor Urquidi', '359', 1449);
  INSERT INTO DIRECCION VALUES (1121, 'Cala Cala', 'Av. Libertador', '366', 1449);
  INSERT INTO DIRECCION VALUES (1122, 'Queru Queru', 'Av. Melchor Urquidi', '355', 1450);
  INSERT INTO DIRECCION VALUES (1123, 'Cala Cala', 'Av. Libertador', '362', 1450);
  INSERT INTO DIRECCION VALUES (1124, 'Centro', 'Calle Ayacucho', '369', 1450);
  COMMIT;
END;
 



BEGIN
  -- 80% (1 sola dirección)
  INSERT INTO DIRECCION VALUES (1125, 'Cala Cala', 'Av. Libertador', '358', 1451);
  INSERT INTO DIRECCION VALUES (1126, 'Centro', 'Calle Ayacucho', '361', 1452);
  INSERT INTO DIRECCION VALUES (1127, 'Achumani', 'Calle 22', '364', 1453);
  INSERT INTO DIRECCION VALUES (1128, 'Irpavi', 'Calle 10', '367', 1454);
  INSERT INTO DIRECCION VALUES (1129, 'Cota Cota', 'Calle 35', '370', 1455);
  INSERT INTO DIRECCION VALUES (1130, 'Sopocachi', 'Av. Ecuador', '373', 1456);
  INSERT INTO DIRECCION VALUES (1131, 'Miraflores', 'Av. Busch', '376', 1457);
  INSERT INTO DIRECCION VALUES (1132, 'Obrajes', 'Calle 16', '379', 1458);
  INSERT INTO DIRECCION VALUES (1133, 'Calacoto', 'Calle 21', '382', 1459);
  INSERT INTO DIRECCION VALUES (1134, 'San Miguel', 'Av. Montenegro', '385', 1460);
  INSERT INTO DIRECCION VALUES (1135, 'Equipetrol', 'Av. San Martín', '388', 1461);
  INSERT INTO DIRECCION VALUES (1136, 'Urbari', 'Calle 3', '391', 1462);
  INSERT INTO DIRECCION VALUES (1137, 'Plan 3000', 'Av. Principal', '394', 1463);
  INSERT INTO DIRECCION VALUES (1138, 'Queru Queru', 'Av. Melchor Urquidi', '397', 1464);
  INSERT INTO DIRECCION VALUES (1139, 'Cala Cala', 'Av. Libertador', '400', 1465);
  INSERT INTO DIRECCION VALUES (1140, 'Centro', 'Calle Ayacucho', '403', 1466);
  INSERT INTO DIRECCION VALUES (1141, 'Achumani', 'Calle 22', '406', 1467);
  INSERT INTO DIRECCION VALUES (1142, 'Irpavi', 'Calle 10', '409', 1468);
  INSERT INTO DIRECCION VALUES (1143, 'Cota Cota', 'Calle 35', '412', 1469);
  INSERT INTO DIRECCION VALUES (1144, 'Sopocachi', 'Av. Ecuador', '415', 1470);
  INSERT INTO DIRECCION VALUES (1145, 'Miraflores', 'Av. Busch', '418', 1471);
  INSERT INTO DIRECCION VALUES (1146, 'Obrajes', 'Calle 16', '421', 1472);
  INSERT INTO DIRECCION VALUES (1147, 'Calacoto', 'Calle 21', '424', 1473);
  INSERT INTO DIRECCION VALUES (1148, 'San Miguel', 'Av. Montenegro', '427', 1474);
  INSERT INTO DIRECCION VALUES (1149, 'Equipetrol', 'Av. San Martín', '430', 1475);
  INSERT INTO DIRECCION VALUES (1150, 'Urbari', 'Calle 3', '433', 1476);
  INSERT INTO DIRECCION VALUES (1151, 'Plan 3000', 'Av. Principal', '436', 1477);
  INSERT INTO DIRECCION VALUES (1152, 'Queru Queru', 'Av. Melchor Urquidi', '439', 1478);
  INSERT INTO DIRECCION VALUES (1153, 'Cala Cala', 'Av. Libertador', '442', 1479);
  INSERT INTO DIRECCION VALUES (1154, 'Centro', 'Calle Ayacucho', '445', 1480);
  INSERT INTO DIRECCION VALUES (1155, 'Achumani', 'Calle 22', '448', 1481);
  INSERT INTO DIRECCION VALUES (1156, 'Irpavi', 'Calle 10', '451', 1482);
  INSERT INTO DIRECCION VALUES (1157, 'Cota Cota', 'Calle 35', '454', 1483);
  INSERT INTO DIRECCION VALUES (1158, 'Sopocachi', 'Av. Ecuador', '457', 1484);
  INSERT INTO DIRECCION VALUES (1159, 'Miraflores', 'Av. Busch', '460', 1485);
  INSERT INTO DIRECCION VALUES (1160, 'Obrajes', 'Calle 16', '463', 1486);
  INSERT INTO DIRECCION VALUES (1161, 'Calacoto', 'Calle 21', '466', 1487);
  INSERT INTO DIRECCION VALUES (1162, 'San Miguel', 'Av. Montenegro', '469', 1488);
  INSERT INTO DIRECCION VALUES (1163, 'Equipetrol', 'Av. San Martín', '472', 1489);
  INSERT INTO DIRECCION VALUES (1164, 'Urbari', 'Calle 3', '475', 1490);
  INSERT INTO DIRECCION VALUES (1165, 'Plan 3000', 'Av. Principal', '478', 1491);
  INSERT INTO DIRECCION VALUES (1166, 'Queru Queru', 'Av. Melchor Urquidi', '481', 1492);
  INSERT INTO DIRECCION VALUES (1167, 'Cala Cala', 'Av. Libertador', '484', 1493);
  INSERT INTO DIRECCION VALUES (1168, 'Centro', 'Calle Ayacucho', '487', 1494);
  INSERT INTO DIRECCION VALUES (1169, 'Achumani', 'Calle 22', '490', 1495);
  INSERT INTO DIRECCION VALUES (1170, 'Irpavi', 'Calle 10', '493', 1496);
  INSERT INTO DIRECCION VALUES (1171, 'Cota Cota', 'Calle 35', '496', 1497);
  INSERT INTO DIRECCION VALUES (1172, 'Sopocachi', 'Av. Ecuador', '499', 1498);
  INSERT INTO DIRECCION VALUES (1173, 'Miraflores', 'Av. Busch', '502', 1499);
  INSERT INTO DIRECCION VALUES (1174, 'Obrajes', 'Calle 16', '505', 1500);
  INSERT INTO DIRECCION VALUES (1175, 'Calacoto', 'Calle 21', '508', 1501);
  INSERT INTO DIRECCION VALUES (1176, 'San Miguel', 'Av. Montenegro', '511', 1502);
  INSERT INTO DIRECCION VALUES (1177, 'Equipetrol', 'Av. San Martín', '514', 1503);
  INSERT INTO DIRECCION VALUES (1178, 'Urbari', 'Calle 3', '517', 1504);
  INSERT INTO DIRECCION VALUES (1179, 'Plan 3000', 'Av. Principal', '520', 1505);
  INSERT INTO DIRECCION VALUES (1180, 'Queru Queru', 'Av. Melchor Urquidi', '523', 1506);
  INSERT INTO DIRECCION VALUES (1181, 'Cala Cala', 'Av. Libertador', '526', 1507);
  INSERT INTO DIRECCION VALUES (1182, 'Centro', 'Calle Ayacucho', '529', 1508);
  INSERT INTO DIRECCION VALUES (1183, 'Achumani', 'Calle 22', '532', 1509);
  INSERT INTO DIRECCION VALUES (1184, 'Irpavi', 'Calle 10', '535', 1510);
  INSERT INTO DIRECCION VALUES (1185, 'Cota Cota', 'Calle 35', '538', 1511);
  INSERT INTO DIRECCION VALUES (1186, 'Sopocachi', 'Av. Ecuador', '541', 1512);
  INSERT INTO DIRECCION VALUES (1187, 'Miraflores', 'Av. Busch', '544', 1513);
  INSERT INTO DIRECCION VALUES (1188, 'Obrajes', 'Calle 16', '547', 1514);
  INSERT INTO DIRECCION VALUES (1189, 'Calacoto', 'Calle 21', '550', 1515);
  INSERT INTO DIRECCION VALUES (1190, 'San Miguel', 'Av. Montenegro', '553', 1516);
  INSERT INTO DIRECCION VALUES (1191, 'Equipetrol', 'Av. San Martín', '556', 1517);
  INSERT INTO DIRECCION VALUES (1192, 'Urbari', 'Calle 3', '559', 1518);
  INSERT INTO DIRECCION VALUES (1193, 'Plan 3000', 'Av. Principal', '562', 1519);
  INSERT INTO DIRECCION VALUES (1194, 'Queru Queru', 'Av. Melchor Urquidi', '565', 1520);
  INSERT INTO DIRECCION VALUES (1195, 'Cala Cala', 'Av. Libertador', '568', 1521);
  INSERT INTO DIRECCION VALUES (1196, 'Centro', 'Calle Ayacucho', '571', 1522);
  INSERT INTO DIRECCION VALUES (1197, 'Achumani', 'Calle 22', '574', 1523);
  INSERT INTO DIRECCION VALUES (1198, 'Irpavi', 'Calle 10', '577', 1524);
  INSERT INTO DIRECCION VALUES (1199, 'Cota Cota', 'Calle 35', '580', 1525);
  INSERT INTO DIRECCION VALUES (1200, 'Sopocachi', 'Av. Ecuador', '583', 1526);
  INSERT INTO DIRECCION VALUES (1201, 'Miraflores', 'Av. Busch', '586', 1527);
  INSERT INTO DIRECCION VALUES (1202, 'Obrajes', 'Calle 16', '589', 1528);
  INSERT INTO DIRECCION VALUES (1203, 'Calacoto', 'Calle 21', '592', 1529);
  INSERT INTO DIRECCION VALUES (1204, 'San Miguel', 'Av. Montenegro', '595', 1530);

  -- 15% (2 direcciones: casa y trabajo)
  INSERT INTO DIRECCION VALUES (1205, 'Equipetrol', 'Av. San Martín', '598', 1531);
  INSERT INTO DIRECCION VALUES (1206, 'Urbari', 'Calle 3', '605', 1531);
  INSERT INTO DIRECCION VALUES (1207, 'Urbari', 'Calle 3', '601', 1532);
  INSERT INTO DIRECCION VALUES (1208, 'Plan 3000', 'Av. Principal', '608', 1532);
  INSERT INTO DIRECCION VALUES (1209, 'Plan 3000', 'Av. Principal', '604', 1533);
  INSERT INTO DIRECCION VALUES (1210, 'Queru Queru', 'Av. Melchor Urquidi', '611', 1533);
  INSERT INTO DIRECCION VALUES (1211, 'Queru Queru', 'Av. Melchor Urquidi', '607', 1534);
  INSERT INTO DIRECCION VALUES (1212, 'Cala Cala', 'Av. Libertador', '614', 1534);
  INSERT INTO DIRECCION VALUES (1213, 'Cala Cala', 'Av. Libertador', '610', 1535);
  INSERT INTO DIRECCION VALUES (1214, 'Centro', 'Calle Ayacucho', '617', 1535);
  INSERT INTO DIRECCION VALUES (1215, 'Centro', 'Calle Ayacucho', '613', 1536);
  INSERT INTO DIRECCION VALUES (1216, 'Achumani', 'Calle 22', '620', 1536);
  INSERT INTO DIRECCION VALUES (1217, 'Achumani', 'Calle 22', '616', 1537);
  INSERT INTO DIRECCION VALUES (1218, 'Irpavi', 'Calle 10', '623', 1537);
  INSERT INTO DIRECCION VALUES (1219, 'Irpavi', 'Calle 10', '619', 1538);
  INSERT INTO DIRECCION VALUES (1220, 'Cota Cota', 'Calle 35', '626', 1538);
  INSERT INTO DIRECCION VALUES (1221, 'Cota Cota', 'Calle 35', '622', 1539);
  INSERT INTO DIRECCION VALUES (1222, 'Sopocachi', 'Av. Ecuador', '629', 1539);
  INSERT INTO DIRECCION VALUES (1223, 'Sopocachi', 'Av. Ecuador', '625', 1540);
  INSERT INTO DIRECCION VALUES (1224, 'Miraflores', 'Av. Busch', '632', 1540);
  INSERT INTO DIRECCION VALUES (1225, 'Miraflores', 'Av. Busch', '628', 1541);
  INSERT INTO DIRECCION VALUES (1226, 'Obrajes', 'Calle 16', '635', 1541);
  INSERT INTO DIRECCION VALUES (1227, 'Obrajes', 'Calle 16', '631', 1542);
  INSERT INTO DIRECCION VALUES (1228, 'Calacoto', 'Calle 21', '638', 1542);
  INSERT INTO DIRECCION VALUES (1229, 'Calacoto', 'Calle 21', '634', 1543);
  INSERT INTO DIRECCION VALUES (1230, 'San Miguel', 'Av. Montenegro', '641', 1543);
  INSERT INTO DIRECCION VALUES (1231, 'San Miguel', 'Av. Montenegro', '637', 1544);
  INSERT INTO DIRECCION VALUES (1232, 'Equipetrol', 'Av. San Martín', '644', 1544);
  INSERT INTO DIRECCION VALUES (1233, 'Equipetrol', 'Av. San Martín', '640', 1545);
  INSERT INTO DIRECCION VALUES (1234, 'Urbari', 'Calle 3', '647', 1545);

  -- 5% (3 direcciones: los jefes)
  INSERT INTO DIRECCION VALUES (1235, 'Urbari', 'Calle 3', '643', 1546);
  INSERT INTO DIRECCION VALUES (1236, 'Plan 3000', 'Av. Principal', '650', 1546);
  INSERT INTO DIRECCION VALUES (1237, 'Queru Queru', 'Av. Melchor Urquidi', '657', 1546);
  INSERT INTO DIRECCION VALUES (1238, 'Plan 3000', 'Av. Principal', '646', 1547);
  INSERT INTO DIRECCION VALUES (1239, 'Queru Queru', 'Av. Melchor Urquidi', '653', 1547);
  INSERT INTO DIRECCION VALUES (1240, 'Cala Cala', 'Av. Libertador', '660', 1547);
  INSERT INTO DIRECCION VALUES (1241, 'Queru Queru', 'Av. Melchor Urquidi', '649', 1548);
  INSERT INTO DIRECCION VALUES (1242, 'Cala Cala', 'Av. Libertador', '656', 1548);
  INSERT INTO DIRECCION VALUES (1243, 'Centro', 'Calle Ayacucho', '663', 1548);
  INSERT INTO DIRECCION VALUES (1244, 'Cala Cala', 'Av. Libertador', '652', 1549);
  INSERT INTO DIRECCION VALUES (1245, 'Centro', 'Calle Ayacucho', '659', 1549);
  INSERT INTO DIRECCION VALUES (1246, 'Achumani', 'Calle 22', '666', 1549);
  INSERT INTO DIRECCION VALUES (1247, 'Centro', 'Calle Ayacucho', '655', 1550);
  INSERT INTO DIRECCION VALUES (1248, 'Achumani', 'Calle 22', '662', 1550);
  INSERT INTO DIRECCION VALUES (1249, 'Irpavi', 'Calle 10', '669', 1550);
  COMMIT;
END;



BEGIN
  -- 80% (1 sola dirección)
  INSERT INTO DIRECCION VALUES (1250, 'Achumani', 'Calle 22', '658', 1551);
  INSERT INTO DIRECCION VALUES (1251, 'Irpavi', 'Calle 10', '661', 1552);
  INSERT INTO DIRECCION VALUES (1252, 'Cota Cota', 'Calle 35', '664', 1553);
  INSERT INTO DIRECCION VALUES (1253, 'Sopocachi', 'Av. Ecuador', '667', 1554);
  INSERT INTO DIRECCION VALUES (1254, 'Miraflores', 'Av. Busch', '670', 1555);
  INSERT INTO DIRECCION VALUES (1255, 'Obrajes', 'Calle 16', '673', 1556);
  INSERT INTO DIRECCION VALUES (1256, 'Calacoto', 'Calle 21', '676', 1557);
  INSERT INTO DIRECCION VALUES (1257, 'San Miguel', 'Av. Montenegro', '679', 1558);
  INSERT INTO DIRECCION VALUES (1258, 'Equipetrol', 'Av. San Martín', '682', 1559);
  INSERT INTO DIRECCION VALUES (1259, 'Urbari', 'Calle 3', '685', 1560);
  INSERT INTO DIRECCION VALUES (1260, 'Plan 3000', 'Av. Principal', '688', 1561);
  INSERT INTO DIRECCION VALUES (1261, 'Queru Queru', 'Av. Melchor Urquidi', '691', 1562);
  INSERT INTO DIRECCION VALUES (1262, 'Cala Cala', 'Av. Libertador', '694', 1563);
  INSERT INTO DIRECCION VALUES (1263, 'Centro', 'Calle Ayacucho', '697', 1564);
  INSERT INTO DIRECCION VALUES (1264, 'Achumani', 'Calle 22', '700', 1565);
  INSERT INTO DIRECCION VALUES (1265, 'Irpavi', 'Calle 10', '703', 1566);
  INSERT INTO DIRECCION VALUES (1266, 'Cota Cota', 'Calle 35', '706', 1567);
  INSERT INTO DIRECCION VALUES (1267, 'Sopocachi', 'Av. Ecuador', '709', 1568);
  INSERT INTO DIRECCION VALUES (1268, 'Miraflores', 'Av. Busch', '712', 1569);
  INSERT INTO DIRECCION VALUES (1269, 'Obrajes', 'Calle 16', '715', 1570);
  INSERT INTO DIRECCION VALUES (1270, 'Calacoto', 'Calle 21', '718', 1571);
  INSERT INTO DIRECCION VALUES (1271, 'San Miguel', 'Av. Montenegro', '721', 1572);
  INSERT INTO DIRECCION VALUES (1272, 'Equipetrol', 'Av. San Martín', '724', 1573);
  INSERT INTO DIRECCION VALUES (1273, 'Urbari', 'Calle 3', '727', 1574);
  INSERT INTO DIRECCION VALUES (1274, 'Plan 3000', 'Av. Principal', '730', 1575);
  INSERT INTO DIRECCION VALUES (1275, 'Queru Queru', 'Av. Melchor Urquidi', '733', 1576);
  INSERT INTO DIRECCION VALUES (1276, 'Cala Cala', 'Av. Libertador', '736', 1577);
  INSERT INTO DIRECCION VALUES (1277, 'Centro', 'Calle Ayacucho', '739', 1578);
  INSERT INTO DIRECCION VALUES (1278, 'Achumani', 'Calle 22', '742', 1579);
  INSERT INTO DIRECCION VALUES (1279, 'Irpavi', 'Calle 10', '745', 1580);
  INSERT INTO DIRECCION VALUES (1280, 'Cota Cota', 'Calle 35', '748', 1581);
  INSERT INTO DIRECCION VALUES (1281, 'Sopocachi', 'Av. Ecuador', '751', 1582);
  INSERT INTO DIRECCION VALUES (1282, 'Miraflores', 'Av. Busch', '754', 1583);
  INSERT INTO DIRECCION VALUES (1283, 'Obrajes', 'Calle 16', '757', 1584);
  INSERT INTO DIRECCION VALUES (1284, 'Calacoto', 'Calle 21', '760', 1585);
  INSERT INTO DIRECCION VALUES (1285, 'San Miguel', 'Av. Montenegro', '763', 1586);
  INSERT INTO DIRECCION VALUES (1286, 'Equipetrol', 'Av. San Martín', '766', 1587);
  INSERT INTO DIRECCION VALUES (1287, 'Urbari', 'Calle 3', '769', 1588);
  INSERT INTO DIRECCION VALUES (1288, 'Plan 3000', 'Av. Principal', '772', 1589);
  INSERT INTO DIRECCION VALUES (1289, 'Queru Queru', 'Av. Melchor Urquidi', '775', 1590);
  INSERT INTO DIRECCION VALUES (1290, 'Cala Cala', 'Av. Libertador', '778', 1591);
  INSERT INTO DIRECCION VALUES (1291, 'Centro', 'Calle Ayacucho', '781', 1592);
  INSERT INTO DIRECCION VALUES (1292, 'Achumani', 'Calle 22', '784', 1593);
  INSERT INTO DIRECCION VALUES (1293, 'Irpavi', 'Calle 10', '787', 1594);
  INSERT INTO DIRECCION VALUES (1294, 'Cota Cota', 'Calle 35', '790', 1595);
  INSERT INTO DIRECCION VALUES (1295, 'Sopocachi', 'Av. Ecuador', '793', 1596);
  INSERT INTO DIRECCION VALUES (1296, 'Miraflores', 'Av. Busch', '796', 1597);
  INSERT INTO DIRECCION VALUES (1297, 'Obrajes', 'Calle 16', '799', 1598);
  INSERT INTO DIRECCION VALUES (1298, 'Calacoto', 'Calle 21', '802', 1599);
  INSERT INTO DIRECCION VALUES (1299, 'San Miguel', 'Av. Montenegro', '805', 1600);
  INSERT INTO DIRECCION VALUES (1300, 'Equipetrol', 'Av. San Martín', '808', 1601);
  INSERT INTO DIRECCION VALUES (1301, 'Urbari', 'Calle 3', '811', 1602);
  INSERT INTO DIRECCION VALUES (1302, 'Plan 3000', 'Av. Principal', '814', 1603);
  INSERT INTO DIRECCION VALUES (1303, 'Queru Queru', 'Av. Melchor Urquidi', '817', 1604);
  INSERT INTO DIRECCION VALUES (1304, 'Cala Cala', 'Av. Libertador', '820', 1605);
  INSERT INTO DIRECCION VALUES (1305, 'Centro', 'Calle Ayacucho', '823', 1606);
  INSERT INTO DIRECCION VALUES (1306, 'Achumani', 'Calle 22', '826', 1607);
  INSERT INTO DIRECCION VALUES (1307, 'Irpavi', 'Calle 10', '829', 1608);
  INSERT INTO DIRECCION VALUES (1308, 'Cota Cota', 'Calle 35', '832', 1609);
  INSERT INTO DIRECCION VALUES (1309, 'Sopocachi', 'Av. Ecuador', '835', 1610);
  INSERT INTO DIRECCION VALUES (1310, 'Miraflores', 'Av. Busch', '838', 1611);
  INSERT INTO DIRECCION VALUES (1311, 'Obrajes', 'Calle 16', '841', 1612);
  INSERT INTO DIRECCION VALUES (1312, 'Calacoto', 'Calle 21', '844', 1613);
  INSERT INTO DIRECCION VALUES (1313, 'San Miguel', 'Av. Montenegro', '847', 1614);
  INSERT INTO DIRECCION VALUES (1314, 'Equipetrol', 'Av. San Martín', '850', 1615);
  INSERT INTO DIRECCION VALUES (1315, 'Urbari', 'Calle 3', '853', 1616);
  INSERT INTO DIRECCION VALUES (1316, 'Plan 3000', 'Av. Principal', '856', 1617);
  INSERT INTO DIRECCION VALUES (1317, 'Queru Queru', 'Av. Melchor Urquidi', '859', 1618);
  INSERT INTO DIRECCION VALUES (1318, 'Cala Cala', 'Av. Libertador', '862', 1619);
  INSERT INTO DIRECCION VALUES (1319, 'Centro', 'Calle Ayacucho', '865', 1620);
  INSERT INTO DIRECCION VALUES (1320, 'Achumani', 'Calle 22', '868', 1621);
  INSERT INTO DIRECCION VALUES (1321, 'Irpavi', 'Calle 10', '871', 1622);
  INSERT INTO DIRECCION VALUES (1322, 'Cota Cota', 'Calle 35', '874', 1623);
  INSERT INTO DIRECCION VALUES (1323, 'Sopocachi', 'Av. Ecuador', '877', 1624);
  INSERT INTO DIRECCION VALUES (1324, 'Miraflores', 'Av. Busch', '880', 1625);
  INSERT INTO DIRECCION VALUES (1325, 'Obrajes', 'Calle 16', '883', 1626);
  INSERT INTO DIRECCION VALUES (1326, 'Calacoto', 'Calle 21', '886', 1627);
  INSERT INTO DIRECCION VALUES (1327, 'San Miguel', 'Av. Montenegro', '889', 1628);
  INSERT INTO DIRECCION VALUES (1328, 'Equipetrol', 'Av. San Martín', '892', 1629);
  INSERT INTO DIRECCION VALUES (1329, 'Urbari', 'Calle 3', '895', 1630);

  -- 15% (2 direcciones: casa y trabajo)
  INSERT INTO DIRECCION VALUES (1330, 'Plan 3000', 'Av. Principal', '898', 1631);
  INSERT INTO DIRECCION VALUES (1331, 'Queru Queru', 'Av. Melchor Urquidi', '905', 1631);
  INSERT INTO DIRECCION VALUES (1332, 'Queru Queru', 'Av. Melchor Urquidi', '901', 1632);
  INSERT INTO DIRECCION VALUES (1333, 'Cala Cala', 'Av. Libertador', '908', 1632);
  INSERT INTO DIRECCION VALUES (1334, 'Cala Cala', 'Av. Libertador', '904', 1633);
  INSERT INTO DIRECCION VALUES (1335, 'Centro', 'Calle Ayacucho', '911', 1633);
  INSERT INTO DIRECCION VALUES (1336, 'Centro', 'Calle Ayacucho', '907', 1634);
  INSERT INTO DIRECCION VALUES (1337, 'Achumani', 'Calle 22', '914', 1634);
  INSERT INTO DIRECCION VALUES (1338, 'Achumani', 'Calle 22', '910', 1635);
  INSERT INTO DIRECCION VALUES (1339, 'Irpavi', 'Calle 10', '917', 1635);
  INSERT INTO DIRECCION VALUES (1340, 'Irpavi', 'Calle 10', '913', 1636);
  INSERT INTO DIRECCION VALUES (1341, 'Cota Cota', 'Calle 35', '920', 1636);
  INSERT INTO DIRECCION VALUES (1342, 'Cota Cota', 'Calle 35', '916', 1637);
  INSERT INTO DIRECCION VALUES (1343, 'Sopocachi', 'Av. Ecuador', '923', 1637);
  INSERT INTO DIRECCION VALUES (1344, 'Sopocachi', 'Av. Ecuador', '919', 1638);
  INSERT INTO DIRECCION VALUES (1345, 'Miraflores', 'Av. Busch', '926', 1638);
  INSERT INTO DIRECCION VALUES (1346, 'Miraflores', 'Av. Busch', '922', 1639);
  INSERT INTO DIRECCION VALUES (1347, 'Obrajes', 'Calle 16', '929', 1639);
  INSERT INTO DIRECCION VALUES (1348, 'Obrajes', 'Calle 16', '925', 1640);
  INSERT INTO DIRECCION VALUES (1349, 'Calacoto', 'Calle 21', '932', 1640);
  INSERT INTO DIRECCION VALUES (1350, 'Calacoto', 'Calle 21', '928', 1641);
  INSERT INTO DIRECCION VALUES (1351, 'San Miguel', 'Av. Montenegro', '935', 1641);
  INSERT INTO DIRECCION VALUES (1352, 'San Miguel', 'Av. Montenegro', '931', 1642);
  INSERT INTO DIRECCION VALUES (1353, 'Equipetrol', 'Av. San Martín', '938', 1642);
  INSERT INTO DIRECCION VALUES (1354, 'Equipetrol', 'Av. San Martín', '934', 1643);
  INSERT INTO DIRECCION VALUES (1355, 'Urbari', 'Calle 3', '941', 1643);
  INSERT INTO DIRECCION VALUES (1356, 'Urbari', 'Calle 3', '937', 1644);
  INSERT INTO DIRECCION VALUES (1357, 'Plan 3000', 'Av. Principal', '944', 1644);
  INSERT INTO DIRECCION VALUES (1358, 'Plan 3000', 'Av. Principal', '940', 1645);
  INSERT INTO DIRECCION VALUES (1359, 'Queru Queru', 'Av. Melchor Urquidi', '947', 1645);

  -- 5% (3 direcciones: los jefes)
  INSERT INTO DIRECCION VALUES (1360, 'Queru Queru', 'Av. Melchor Urquidi', '943', 1646);
  INSERT INTO DIRECCION VALUES (1361, 'Cala Cala', 'Av. Libertador', '950', 1646);
  INSERT INTO DIRECCION VALUES (1362, 'Centro', 'Calle Ayacucho', '957', 1646);
  INSERT INTO DIRECCION VALUES (1363, 'Cala Cala', 'Av. Libertador', '946', 1647);
  INSERT INTO DIRECCION VALUES (1364, 'Centro', 'Calle Ayacucho', '953', 1647);
  INSERT INTO DIRECCION VALUES (1365, 'Achumani', 'Calle 22', '960', 1647);
  INSERT INTO DIRECCION VALUES (1366, 'Centro', 'Calle Ayacucho', '949', 1648);
  INSERT INTO DIRECCION VALUES (1367, 'Achumani', 'Calle 22', '956', 1648);
  INSERT INTO DIRECCION VALUES (1368, 'Irpavi', 'Calle 10', '963', 1648);
  INSERT INTO DIRECCION VALUES (1369, 'Achumani', 'Calle 22', '952', 1649);
  INSERT INTO DIRECCION VALUES (1370, 'Irpavi', 'Calle 10', '959', 1649);
  INSERT INTO DIRECCION VALUES (1371, 'Cota Cota', 'Calle 35', '966', 1649);
  INSERT INTO DIRECCION VALUES (1372, 'Irpavi', 'Calle 10', '955', 1650);
  INSERT INTO DIRECCION VALUES (1373, 'Cota Cota', 'Calle 35', '962', 1650);
  INSERT INTO DIRECCION VALUES (1374, 'Sopocachi', 'Av. Ecuador', '969', 1650);
  COMMIT;
END;

BEGIN
  -- 80% (1 sola dirección)
  INSERT INTO DIRECCION VALUES (1375, 'Cota Cota', 'Calle 35', '958', 1651);
  INSERT INTO DIRECCION VALUES (1376, 'Sopocachi', 'Av. Ecuador', '961', 1652);
  INSERT INTO DIRECCION VALUES (1377, 'Miraflores', 'Av. Busch', '964', 1653);
  INSERT INTO DIRECCION VALUES (1378, 'Obrajes', 'Calle 16', '967', 1654);
  INSERT INTO DIRECCION VALUES (1379, 'Calacoto', 'Calle 21', '970', 1655);
  INSERT INTO DIRECCION VALUES (1380, 'San Miguel', 'Av. Montenegro', '973', 1656);
  INSERT INTO DIRECCION VALUES (1381, 'Equipetrol', 'Av. San Martín', '976', 1657);
  INSERT INTO DIRECCION VALUES (1382, 'Urbari', 'Calle 3', '979', 1658);
  INSERT INTO DIRECCION VALUES (1383, 'Plan 3000', 'Av. Principal', '982', 1659);
  INSERT INTO DIRECCION VALUES (1384, 'Queru Queru', 'Av. Melchor Urquidi', '985', 1660);
  INSERT INTO DIRECCION VALUES (1385, 'Cala Cala', 'Av. Libertador', '988', 1661);
  INSERT INTO DIRECCION VALUES (1386, 'Centro', 'Calle Ayacucho', '991', 1662);
  INSERT INTO DIRECCION VALUES (1387, 'Achumani', 'Calle 22', '994', 1663);
  INSERT INTO DIRECCION VALUES (1388, 'Irpavi', 'Calle 10', '997', 1664);
  INSERT INTO DIRECCION VALUES (1389, 'Cota Cota', 'Calle 35', '1000', 1665);
  INSERT INTO DIRECCION VALUES (1390, 'Sopocachi', 'Av. Ecuador', '1003', 1666);
  INSERT INTO DIRECCION VALUES (1391, 'Miraflores', 'Av. Busch', '1006', 1667);
  INSERT INTO DIRECCION VALUES (1392, 'Obrajes', 'Calle 16', '1009', 1668);
  INSERT INTO DIRECCION VALUES (1393, 'Calacoto', 'Calle 21', '1012', 1669);
  INSERT INTO DIRECCION VALUES (1394, 'San Miguel', 'Av. Montenegro', '1015', 1670);
  INSERT INTO DIRECCION VALUES (1395, 'Equipetrol', 'Av. San Martín', '1018', 1671);
  INSERT INTO DIRECCION VALUES (1396, 'Urbari', 'Calle 3', '1021', 1672);
  INSERT INTO DIRECCION VALUES (1397, 'Plan 3000', 'Av. Principal', '1024', 1673);
  INSERT INTO DIRECCION VALUES (1398, 'Queru Queru', 'Av. Melchor Urquidi', '1027', 1674);
  INSERT INTO DIRECCION VALUES (1399, 'Cala Cala', 'Av. Libertador', '1030', 1675);
  INSERT INTO DIRECCION VALUES (1400, 'Centro', 'Calle Ayacucho', '1033', 1676);
  INSERT INTO DIRECCION VALUES (1401, 'Achumani', 'Calle 22', '1036', 1677);
  INSERT INTO DIRECCION VALUES (1402, 'Irpavi', 'Calle 10', '1039', 1678);
  INSERT INTO DIRECCION VALUES (1403, 'Cota Cota', 'Calle 35', '1042', 1679);
  INSERT INTO DIRECCION VALUES (1404, 'Sopocachi', 'Av. Ecuador', '1045', 1680);
  INSERT INTO DIRECCION VALUES (1405, 'Miraflores', 'Av. Busch', '1048', 1681);
  INSERT INTO DIRECCION VALUES (1406, 'Obrajes', 'Calle 16', '1051', 1682);
  INSERT INTO DIRECCION VALUES (1407, 'Calacoto', 'Calle 21', '1054', 1683);
  INSERT INTO DIRECCION VALUES (1408, 'San Miguel', 'Av. Montenegro', '1057', 1684);
  INSERT INTO DIRECCION VALUES (1409, 'Equipetrol', 'Av. San Martín', '1060', 1685);
  INSERT INTO DIRECCION VALUES (1410, 'Urbari', 'Calle 3', '1063', 1686);
  INSERT INTO DIRECCION VALUES (1411, 'Plan 3000', 'Av. Principal', '1066', 1687);
  INSERT INTO DIRECCION VALUES (1412, 'Queru Queru', 'Av. Melchor Urquidi', '1069', 1688);
  INSERT INTO DIRECCION VALUES (1413, 'Cala Cala', 'Av. Libertador', '1072', 1689);
  INSERT INTO DIRECCION VALUES (1414, 'Centro', 'Calle Ayacucho', '1075', 1690);
  INSERT INTO DIRECCION VALUES (1415, 'Achumani', 'Calle 22', '1078', 1691);
  INSERT INTO DIRECCION VALUES (1416, 'Irpavi', 'Calle 10', '1081', 1692);
  INSERT INTO DIRECCION VALUES (1417, 'Cota Cota', 'Calle 35', '1084', 1693);
  INSERT INTO DIRECCION VALUES (1418, 'Sopocachi', 'Av. Ecuador', '1087', 1694);
  INSERT INTO DIRECCION VALUES (1419, 'Miraflores', 'Av. Busch', '1090', 1695);
  INSERT INTO DIRECCION VALUES (1420, 'Obrajes', 'Calle 16', '1093', 1696);
  INSERT INTO DIRECCION VALUES (1421, 'Calacoto', 'Calle 21', '1096', 1697);
  INSERT INTO DIRECCION VALUES (1422, 'San Miguel', 'Av. Montenegro', '1099', 1698);
  INSERT INTO DIRECCION VALUES (1423, 'Equipetrol', 'Av. San Martín', '1102', 1699);
  INSERT INTO DIRECCION VALUES (1424, 'Urbari', 'Calle 3', '1105', 1700);
  INSERT INTO DIRECCION VALUES (1425, 'Plan 3000', 'Av. Principal', '1108', 1701);
  INSERT INTO DIRECCION VALUES (1426, 'Queru Queru', 'Av. Melchor Urquidi', '1111', 1702);
  INSERT INTO DIRECCION VALUES (1427, 'Cala Cala', 'Av. Libertador', '1114', 1703);
  INSERT INTO DIRECCION VALUES (1428, 'Centro', 'Calle Ayacucho', '1117', 1704);
  INSERT INTO DIRECCION VALUES (1429, 'Achumani', 'Calle 22', '1120', 1705);
  INSERT INTO DIRECCION VALUES (1430, 'Irpavi', 'Calle 10', '1123', 1706);
  INSERT INTO DIRECCION VALUES (1431, 'Cota Cota', 'Calle 35', '1126', 1707);
  INSERT INTO DIRECCION VALUES (1432, 'Sopocachi', 'Av. Ecuador', '1129', 1708);
  INSERT INTO DIRECCION VALUES (1433, 'Miraflores', 'Av. Busch', '1132', 1709);
  INSERT INTO DIRECCION VALUES (1434, 'Obrajes', 'Calle 16', '1135', 1710);
  INSERT INTO DIRECCION VALUES (1435, 'Calacoto', 'Calle 21', '1138', 1711);
  INSERT INTO DIRECCION VALUES (1436, 'San Miguel', 'Av. Montenegro', '1141', 1712);
  INSERT INTO DIRECCION VALUES (1437, 'Equipetrol', 'Av. San Martín', '1144', 1713);
  INSERT INTO DIRECCION VALUES (1438, 'Urbari', 'Calle 3', '1147', 1714);
  INSERT INTO DIRECCION VALUES (1439, 'Plan 3000', 'Av. Principal', '1150', 1715);
  INSERT INTO DIRECCION VALUES (1440, 'Queru Queru', 'Av. Melchor Urquidi', '1153', 1716);
  INSERT INTO DIRECCION VALUES (1441, 'Cala Cala', 'Av. Libertador', '1156', 1717);
  INSERT INTO DIRECCION VALUES (1442, 'Centro', 'Calle Ayacucho', '1159', 1718);
  INSERT INTO DIRECCION VALUES (1443, 'Achumani', 'Calle 22', '1162', 1719);
  INSERT INTO DIRECCION VALUES (1444, 'Irpavi', 'Calle 10', '1165', 1720);
  INSERT INTO DIRECCION VALUES (1445, 'Cota Cota', 'Calle 35', '1168', 1721);
  INSERT INTO DIRECCION VALUES (1446, 'Sopocachi', 'Av. Ecuador', '1171', 1722);
  INSERT INTO DIRECCION VALUES (1447, 'Miraflores', 'Av. Busch', '1174', 1723);
  INSERT INTO DIRECCION VALUES (1448, 'Obrajes', 'Calle 16', '1177', 1724);
  INSERT INTO DIRECCION VALUES (1449, 'Calacoto', 'Calle 21', '1180', 1725);
  INSERT INTO DIRECCION VALUES (1450, 'San Miguel', 'Av. Montenegro', '1183', 1726);
  INSERT INTO DIRECCION VALUES (1451, 'Equipetrol', 'Av. San Martín', '1186', 1727);
  INSERT INTO DIRECCION VALUES (1452, 'Urbari', 'Calle 3', '1189', 1728);
  INSERT INTO DIRECCION VALUES (1453, 'Plan 3000', 'Av. Principal', '1192', 1729);
  INSERT INTO DIRECCION VALUES (1454, 'Queru Queru', 'Av. Melchor Urquidi', '1195', 1730);

  -- 15% (2 direcciones: casa y trabajo)
  INSERT INTO DIRECCION VALUES (1455, 'Cala Cala', 'Av. Libertador', '1198', 1731);
  INSERT INTO DIRECCION VALUES (1456, 'Centro', 'Calle Ayacucho', '1205', 1731);
  INSERT INTO DIRECCION VALUES (1457, 'Centro', 'Calle Ayacucho', '1201', 1732);
  INSERT INTO DIRECCION VALUES (1458, 'Achumani', 'Calle 22', '1208', 1732);
  INSERT INTO DIRECCION VALUES (1459, 'Achumani', 'Calle 22', '1204', 1733);
  INSERT INTO DIRECCION VALUES (1460, 'Irpavi', 'Calle 10', '1211', 1733);
  INSERT INTO DIRECCION VALUES (1461, 'Irpavi', 'Calle 10', '1207', 1734);
  INSERT INTO DIRECCION VALUES (1462, 'Cota Cota', 'Calle 35', '1214', 1734);
  INSERT INTO DIRECCION VALUES (1463, 'Cota Cota', 'Calle 35', '1210', 1735);
  INSERT INTO DIRECCION VALUES (1464, 'Sopocachi', 'Av. Ecuador', '1217', 1735);
  INSERT INTO DIRECCION VALUES (1465, 'Sopocachi', 'Av. Ecuador', '1213', 1736);
  INSERT INTO DIRECCION VALUES (1466, 'Miraflores', 'Av. Busch', '1220', 1736);
  INSERT INTO DIRECCION VALUES (1467, 'Miraflores', 'Av. Busch', '1216', 1737);
  INSERT INTO DIRECCION VALUES (1468, 'Obrajes', 'Calle 16', '1223', 1737);
  INSERT INTO DIRECCION VALUES (1469, 'Obrajes', 'Calle 16', '1219', 1738);
  INSERT INTO DIRECCION VALUES (1470, 'Calacoto', 'Calle 21', '1226', 1738);
  INSERT INTO DIRECCION VALUES (1471, 'Calacoto', 'Calle 21', '1222', 1739);
  INSERT INTO DIRECCION VALUES (1472, 'San Miguel', 'Av. Montenegro', '1229', 1739);
  INSERT INTO DIRECCION VALUES (1473, 'San Miguel', 'Av. Montenegro', '1225', 1740);
  INSERT INTO DIRECCION VALUES (1474, 'Equipetrol', 'Av. San Martín', '1232', 1740);
  INSERT INTO DIRECCION VALUES (1475, 'Equipetrol', 'Av. San Martín', '1228', 1741);
  INSERT INTO DIRECCION VALUES (1476, 'Urbari', 'Calle 3', '1235', 1741);
  INSERT INTO DIRECCION VALUES (1477, 'Urbari', 'Calle 3', '1231', 1742);
  INSERT INTO DIRECCION VALUES (1478, 'Plan 3000', 'Av. Principal', '1238', 1742);
  INSERT INTO DIRECCION VALUES (1479, 'Plan 3000', 'Av. Principal', '1234', 1743);
  INSERT INTO DIRECCION VALUES (1480, 'Queru Queru', 'Av. Melchor Urquidi', '1241', 1743);
  INSERT INTO DIRECCION VALUES (1481, 'Queru Queru', 'Av. Melchor Urquidi', '1237', 1744);
  INSERT INTO DIRECCION VALUES (1482, 'Cala Cala', 'Av. Libertador', '1244', 1744);
  INSERT INTO DIRECCION VALUES (1483, 'Cala Cala', 'Av. Libertador', '1240', 1745);
  INSERT INTO DIRECCION VALUES (1484, 'Centro', 'Calle Ayacucho', '1247', 1745);

  -- 5% (3 direcciones: los jefes)
  INSERT INTO DIRECCION VALUES (1485, 'Centro', 'Calle Ayacucho', '1243', 1746);
  INSERT INTO DIRECCION VALUES (1486, 'Achumani', 'Calle 22', '1250', 1746);
  INSERT INTO DIRECCION VALUES (1487, 'Irpavi', 'Calle 10', '1257', 1746);
  INSERT INTO DIRECCION VALUES (1488, 'Achumani', 'Calle 22', '1246', 1747);
  INSERT INTO DIRECCION VALUES (1489, 'Irpavi', 'Calle 10', '1253', 1747);
  INSERT INTO DIRECCION VALUES (1490, 'Cota Cota', 'Calle 35', '1260', 1747);
  INSERT INTO DIRECCION VALUES (1491, 'Irpavi', 'Calle 10', '1249', 1748);
  INSERT INTO DIRECCION VALUES (1492, 'Cota Cota', 'Calle 35', '1256', 1748);
  INSERT INTO DIRECCION VALUES (1493, 'Sopocachi', 'Av. Ecuador', '1263', 1748);
  INSERT INTO DIRECCION VALUES (1494, 'Cota Cota', 'Calle 35', '1252', 1749);
  INSERT INTO DIRECCION VALUES (1495, 'Sopocachi', 'Av. Ecuador', '1259', 1749);
  INSERT INTO DIRECCION VALUES (1496, 'Miraflores', 'Av. Busch', '1266', 1749);
  INSERT INTO DIRECCION VALUES (1497, 'Sopocachi', 'Av. Ecuador', '1255', 1750);
  INSERT INTO DIRECCION VALUES (1498, 'Miraflores', 'Av. Busch', '1262', 1750);
  INSERT INTO DIRECCION VALUES (1499, 'Obrajes', 'Calle 16', '1269', 1750);
  COMMIT;
END;




--NEGOCIO

BEGIN
  INSERT INTO NEGOCIO VALUES (3001, 'Pollos Copacabana', 'Restaurante', '10:00', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3002, 'Pollos Chriss', 'Restaurante', '10:30', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3003, 'Pollos Toby', 'Restaurante', '10:00', '22:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3004, 'Pollos Kingdom', 'Restaurante', '11:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3005, 'Pollos Kiky', 'Restaurante', '10:00', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3006, 'Pollos Panchita', 'Restaurante', '11:00', '22:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3007, 'Pollos Campeón', 'Restaurante', '10:30', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3008, 'Pollos Solar', 'Restaurante', '11:00', '21:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3009, 'Burger King Bolivia', 'Restaurante', '10:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3010, 'McDonald''s', 'Restaurante', '09:00', '23:59', 'Todos los días', 'Activo');
  INSERT INTO NEGOCIO VALUES (3011, 'Casa del Camba', 'Restaurante', '11:30', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3012, 'El Arriero', 'Restaurante', '12:00', '23:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3013, 'Jardín de Asia', 'Restaurante', '12:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3014, 'Factory Grill', 'Restaurante', '12:00', '00:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3015, 'Hard Rock Cafe', 'Restaurante', '12:00', '02:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3016, 'Typica Cafe', 'Cafetería', '07:30', '21:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3017, 'Alexander Coffee', 'Cafetería', '07:00', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3018, 'Roaster Boutique', 'Cafetería', '08:00', '20:00', 'Lunes a Sábado', 'Activo');
  INSERT INTO NEGOCIO VALUES (3019, 'Vainilla Coffee', 'Cafetería', '08:00', '21:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3020, 'Dumbo', 'Restaurante', '09:00', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3021, 'Wist''upiku', 'Panadería', '07:00', '21:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3022, 'Salteñas Castores', 'Restaurante', '08:00', '14:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3023, 'Salteñas Paceñas', 'Restaurante', '07:30', '13:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3024, 'Salteñas Potosinas', 'Restaurante', '08:00', '14:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3025, 'Salteñas El Hornito', 'Restaurante', '07:30', '15:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3026, 'Empanadas Santa Clara', 'Panadería', '07:00', '20:00', 'Lunes a Sábado', 'Activo');
  INSERT INTO NEGOCIO VALUES (3027, 'Panadería Victoria', 'Panadería', '06:00', '21:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3028, 'Panadería San Gabriel', 'Panadería', '06:30', '21:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3029, 'Panadería La Francesa', 'Panadería', '07:00', '21:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3030, 'Panificadora San José', 'Panadería', '06:00', '20:00', 'Lunes a Sábado', 'Activo');
  INSERT INTO NEGOCIO VALUES (3031, 'Farmacorp', 'Farmacia', '07:00', '23:59', 'Todos los días', 'Activo');
  INSERT INTO NEGOCIO VALUES (3032, 'Farmacias Chávez', 'Farmacia', '07:30', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3033, 'Farmacias Bolivia', 'Farmacia', '08:00', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3034, 'Farmacia Telchi', 'Farmacia', '08:00', '22:30', 'Lunes a Sábado', 'Activo');
  INSERT INTO NEGOCIO VALUES (3035, 'Farmacia San Agustín', 'Farmacia', '07:00', '23:59', 'Todos los días', 'Activo');
  INSERT INTO NEGOCIO VALUES (3036, 'Farmacia Señor de Mayo', 'Farmacia', '08:00', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3037, 'Farmacia La Paz', 'Farmacia', '08:30', '21:30', 'Lunes a Sábado', 'Activo');
  INSERT INTO NEGOCIO VALUES (3038, 'Farmacia Cristo Rey', 'Farmacia', '07:30', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3039, 'Farmacia San Pablo', 'Farmacia', '08:00', '21:00', 'Lunes a Sábado', 'Activo');
  INSERT INTO NEGOCIO VALUES (3040, 'Farmacia Lourdes', 'Farmacia', '08:00', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3041, 'Hipermaxi', 'Supermercado', '07:30', '22:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3042, 'Supermercado Ketal', 'Supermercado', '08:00', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3043, 'Supermercados Fidalga', 'Supermercado', '07:30', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3044, 'IC Norte', 'Supermercado', '08:00', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3045, 'Supermercado Tía', 'Supermercado', '08:00', '21:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3046, 'Supermercado SAS', 'Supermercado', '08:30', '21:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3047, 'Súper Sur', 'Supermercado', '08:00', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3048, 'Micromercado Andy', 'Tienda', '07:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3049, 'Micromercado El Paso', 'Tienda', '07:30', '22:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3050, 'Market 24 7', 'Tienda', '00:00', '23:59', 'Todos los días', 'Activo');
  INSERT INTO NEGOCIO VALUES (3051, 'Pizzería Eli''s', 'Restaurante', '11:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3052, 'Pizzería Margarita', 'Restaurante', '12:00', '23:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3053, 'Pizzería D''Italia', 'Restaurante', '12:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3054, 'Pizzería Cozzolisi', 'Restaurante', '11:30', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3055, 'Pizzería Napoli', 'Restaurante', '12:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3056, 'Pizzería Nápoles', 'Restaurante', '11:00', '22:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3057, 'Pizzería La Taverna', 'Restaurante', '12:00', '23:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3058, 'Pizzería Mozzarella', 'Restaurante', '11:30', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3059, 'Pizzería Mamma Mia', 'Restaurante', '12:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3060, 'Pizzería Roma', 'Restaurante', '11:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3061, 'Chifa Lu Qing', 'Restaurante', '11:30', '22:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3062, 'Chifa Rey', 'Restaurante', '12:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3063, 'Chifa Palacio Dragón', 'Restaurante', '11:30', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3064, 'Restaurante Oriental', 'Restaurante', '12:00', '22:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3065, 'Sushi Bar', 'Restaurante', '12:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3066, 'Sushi Pop', 'Restaurante', '11:30', '22:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3067, 'Kenzo Sushi', 'Restaurante', '12:00', '23:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3068, 'Miyako', 'Restaurante', '12:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3069, 'Sakura Sushi', 'Restaurante', '11:30', '22:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3070, 'Wok & Roll', 'Restaurante', '11:00', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3071, 'Bits & Cream', 'Cafetería', '10:00', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3072, 'Vaca Fría', 'Cafetería', '10:30', '22:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3073, 'Yogen Früz', 'Cafetería', '11:00', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3074, 'Heladería Splendid', 'Cafetería', '10:00', '21:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3075, 'Heladería Frigo', 'Cafetería', '09:30', '21:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3076, 'Helados Panda', 'Cafetería', '10:00', '21:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3077, 'Helados Delizia', 'Cafetería', '09:00', '21:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3078, 'Churros Manolo', 'Cafetería', '08:00', '21:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3079, 'Cinnabon', 'Cafetería', '10:00', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3080, 'Donuts Shop', 'Cafetería', '08:30', '21:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3081, 'Churrasquería Palenque', 'Restaurante', '11:30', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3082, 'Churrasquería Los Hierros', 'Restaurante', '12:00', '23:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3083, 'Churrasquería La Tranquera', 'Restaurante', '12:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3084, 'Carnes & Cortes', 'Restaurante', '11:30', '22:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3085, 'Asador El Buen Gusto', 'Restaurante', '12:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3086, 'Parrillada El Rancho', 'Restaurante', '11:30', '22:30', 'Lunes a Sábado', 'Activo');
  INSERT INTO NEGOCIO VALUES (3087, 'Parrillada San Juan', 'Restaurante', '12:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3088, 'El Fogón', 'Restaurante', '11:30', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3089, 'La Brasa', 'Restaurante', '12:00', '23:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3090, 'Grill Master', 'Restaurante', '11:30', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3091, 'Tienda de Licores Baco', 'Tienda', '10:00', '02:00', 'Jueves a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3092, 'Licorería 24 Horas', 'Tienda', '00:00', '23:59', 'Todos los días', 'Activo');
  INSERT INTO NEGOCIO VALUES (3093, 'Market Express', 'Tienda', '07:00', '23:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3094, 'Kiosco El Vecino', 'Tienda', '06:30', '21:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3095, 'Tienda La Caserita', 'Tienda', '07:00', '21:30', 'Lunes a Sábado', 'Activo');
  INSERT INTO NEGOCIO VALUES (3096, 'Minimarket La Esquina', 'Tienda', '07:30', '22:00', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3097, 'Minimarket Central', 'Tienda', '08:00', '22:30', 'Lunes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3098, 'Drugstore La Noche', 'Tienda', '18:00', '03:00', 'Viernes a Domingo', 'Activo');
  INSERT INTO NEGOCIO VALUES (3099, 'Tienda San Pedro', 'Tienda', '07:00', '21:00', 'Lunes a Sábado', 'Activo');
  INSERT INTO NEGOCIO VALUES (3100, 'Tienda El Sol', 'Tienda', '07:30', '22:00', 'Lunes a Domingo', 'Activo');
  COMMIT;
END;
 




--SUCURSAL
BEGIN
  -- Pollos Copacabana (1:4)
  INSERT INTO SUCURSAL VALUES (4001, 'Copacabana El Prado', 'Centro', 'Av. 16 de Julio', 3001);
  INSERT INTO SUCURSAL VALUES (4002, 'Copacabana Miraflores', 'Miraflores', 'Av. Busch', 3001);
  INSERT INTO SUCURSAL VALUES (4003, 'Copacabana Zona Sur', 'Calacoto', 'Av. Ballivián', 3001);
  INSERT INTO SUCURSAL VALUES (4004, 'Copacabana Megacenter', 'Irpavi', 'Av. Rafael Pabón', 3001);
  
  -- Pollos Chriss (1:3)
  INSERT INTO SUCURSAL VALUES (4005, 'Chriss Equipetrol', 'Equipetrol', 'Av. San Martín', 3002);
  INSERT INTO SUCURSAL VALUES (4006, 'Chriss Plan 3000', 'Plan 3000', 'Av. Principal', 3002);
  INSERT INTO SUCURSAL VALUES (4007, 'Chriss Centro', 'Centro', 'Calle René Moreno', 3002);
  
  -- Pollos Toby (1:3)
  INSERT INTO SUCURSAL VALUES (4008, 'Toby Cine Center', 'Trompillo', 'Av. El Trompillo', 3003);
  INSERT INTO SUCURSAL VALUES (4009, 'Toby 2do Anillo', 'Sur', 'Av. 2do Anillo', 3003);
  INSERT INTO SUCURSAL VALUES (4010, 'Toby Norte', 'Banzer', 'Av. Banzer Km 3', 3003);
  
  -- Pollos Kingdom (1:2)
  INSERT INTO SUCURSAL VALUES (4011, 'Kingdom Sopocachi', 'Sopocachi', 'Av. 20 de Octubre', 3004);
  INSERT INTO SUCURSAL VALUES (4012, 'Kingdom Obrajes', 'Obrajes', 'Av. Hernando Siles', 3004);
  
  -- Pollos Kiky (1:2)
  INSERT INTO SUCURSAL VALUES (4013, 'Kiky Central', 'Centro', 'Calle Ayacucho', 3005);
  INSERT INTO SUCURSAL VALUES (4014, 'Kiky Mutualista', 'Villa 1ro de Mayo', 'Av. Mutualista', 3005);
  
  -- Pollos Panchita (1:4)
  INSERT INTO SUCURSAL VALUES (4015, 'Panchita América', 'Norte', 'Av. América', 3006);
  INSERT INTO SUCURSAL VALUES (4016, 'Panchita Quillacollo', 'Sur', 'Av. Blanco Galindo', 3006);
  INSERT INTO SUCURSAL VALUES (4017, 'Panchita Centro', 'Centro', 'Calle San Martín', 3006);
  INSERT INTO SUCURSAL VALUES (4018, 'Panchita Cala Cala', 'Oeste', 'Av. Libertador', 3006);
  
  -- Otros Pollos (1:2)
  INSERT INTO SUCURSAL VALUES (4019, 'Campeón Prado', 'Centro', 'El Prado', 3007);
  INSERT INTO SUCURSAL VALUES (4020, 'Campeón Terminal', 'Norte', 'Av. Perú', 3007);
  INSERT INTO SUCURSAL VALUES (4021, 'Solar Calacoto', 'Calacoto', 'Calle 21', 3008);
  INSERT INTO SUCURSAL VALUES (4022, 'Solar San Miguel', 'San Miguel', 'Calle 22', 3008);
  
  -- Burger King & McDonald's (1:3)
  INSERT INTO SUCURSAL VALUES (4023, 'BK El Prado', 'Centro', 'Av. 16 de Julio', 3009);
  INSERT INTO SUCURSAL VALUES (4024, 'BK Megacenter', 'Irpavi', 'Av. Rafael Pabón', 3009);
  INSERT INTO SUCURSAL VALUES (4025, 'BK Cine Center', 'Trompillo', 'Av. El Trompillo', 3009);
  INSERT INTO SUCURSAL VALUES (4026, 'McDonalds Cristo', 'Centro', 'El Cristo', 3010);
  INSERT INTO SUCURSAL VALUES (4027, 'McDonalds Urubó', 'Urubó', 'Av. Principal Urubó', 3010);
  INSERT INTO SUCURSAL VALUES (4028, 'McDonalds Ventura', 'Equipetrol', 'Mall Ventura', 3010);
  
  -- Restaurantes formales (1:2)
  INSERT INTO SUCURSAL VALUES (4029, 'Casa del Camba Urubó', 'Urubó', 'Camino al Urubó', 3011);
  INSERT INTO SUCURSAL VALUES (4030, 'Casa del Camba 2do Anillo', 'Cristo', '2do Anillo', 3011);
  INSERT INTO SUCURSAL VALUES (4031, 'El Arriero Equipetrol', 'Equipetrol', 'Calle 7 Oeste', 3012);
  INSERT INTO SUCURSAL VALUES (4032, 'El Arriero Centro', 'Centro', 'Calle Velasco', 3012);
  INSERT INTO SUCURSAL VALUES (4033, 'Jardín de Asia SCZ', 'Equipetrol', 'Hotel Los Tajibos', 3013);
  INSERT INTO SUCURSAL VALUES (4034, 'Jardín de Asia LPZ', 'Calacoto', 'Florida', 3013);
  INSERT INTO SUCURSAL VALUES (4035, 'Factory Megacenter', 'Irpavi', 'Av. Rafael Pabón', 3014);
  INSERT INTO SUCURSAL VALUES (4036, 'Factory San Miguel', 'San Miguel', 'Av. Montenegro', 3014);
  INSERT INTO SUCURSAL VALUES (4037, 'Hard Rock SCZ', 'Equipetrol', 'Mall Ventura', 3015);
  INSERT INTO SUCURSAL VALUES (4038, 'Hard Rock LPZ', 'Calacoto', 'Mega', 3015);
  
  -- Cafeterías (1:3 y 1:2)
  INSERT INTO SUCURSAL VALUES (4039, 'Typica Sopocachi', 'Sopocachi', 'Av. 6 de Agosto', 3016);
  INSERT INTO SUCURSAL VALUES (4040, 'Typica San Miguel', 'San Miguel', 'Calle 18', 3016);
  INSERT INTO SUCURSAL VALUES (4041, 'Typica Equipetrol', 'Equipetrol', 'Sirari', 3016);
  INSERT INTO SUCURSAL VALUES (4042, 'Alexander Prado', 'Centro', 'El Prado', 3017);
  INSERT INTO SUCURSAL VALUES (4043, 'Alexander Calacoto', 'Calacoto', 'Calle 21', 3017);
  INSERT INTO SUCURSAL VALUES (4044, 'Alexander Aeropuerto', 'El Alto', 'Aeropuerto Intl', 3017);
  INSERT INTO SUCURSAL VALUES (4045, 'Roaster Sopocachi', 'Sopocachi', 'Av. Ecuador', 3018);
  INSERT INTO SUCURSAL VALUES (4046, 'Roaster Achumani', 'Achumani', 'Calle 22', 3018);
  INSERT INTO SUCURSAL VALUES (4047, 'Vainilla Centro', 'Centro', 'Plaza Avaroa', 3019);
  INSERT INTO SUCURSAL VALUES (4048, 'Vaca Fría San Miguel', 'San Miguel', 'Av. Montenegro', 3019);
  INSERT INTO SUCURSAL VALUES (4049, 'Dumbo Prado', 'Centro', 'El Prado', 3020);
  INSERT INTO SUCURSAL VALUES (4050, 'Dumbo Sur', 'San Miguel', 'Av. Montenegro', 3020);
  
  -- Panaderías y Salteñas (1:2 y 1:3)
  INSERT INTO SUCURSAL VALUES (4051, 'Wistupiku Prado', 'Centro', 'El Prado', 3021);
  INSERT INTO SUCURSAL VALUES (4052, 'Wistupiku América', 'Norte', 'Av. América', 3021);
  INSERT INTO SUCURSAL VALUES (4053, 'Wistupiku Stadium', 'Miraflores', 'Plaza del Stadium', 3021);
  INSERT INTO SUCURSAL VALUES (4054, 'Castores Banzer', 'Banzer', 'Av. Banzer', 3022);
  INSERT INTO SUCURSAL VALUES (4055, 'Castores Centro', 'Centro', 'Calle Ayacucho', 3022);
  INSERT INTO SUCURSAL VALUES (4056, 'Paceñas Sopocachi', 'Sopocachi', 'Av. 20 de Octubre', 3023);
  INSERT INTO SUCURSAL VALUES (4057, 'Paceñas Miraflores', 'Miraflores', 'Plaza Uyuni', 3023);
  INSERT INTO SUCURSAL VALUES (4058, 'Potosinas Centro', 'Centro', 'Plaza San Francisco', 3024);
  INSERT INTO SUCURSAL VALUES (4059, 'Potosinas Obrajes', 'Obrajes', 'Av. Hernando Siles', 3024);
  INSERT INTO SUCURSAL VALUES (4060, 'Hornito SCZ', 'Equipetrol', 'San Martín', 3025);
  INSERT INTO SUCURSAL VALUES (4061, 'Hornito CBBA', 'Norte', 'Av. Pando', 3025);
  INSERT INTO SUCURSAL VALUES (4062, 'Santa Clara Centro', 'Centro', 'Calle Comercio', 3026);
  INSERT INTO SUCURSAL VALUES (4063, 'Victoria Sur', 'Calacoto', 'Calle 15', 3027);
  INSERT INTO SUCURSAL VALUES (4064, 'Victoria Norte', 'Norte', 'Av. Perú', 3027);
  INSERT INTO SUCURSAL VALUES (4065, 'San Gabriel El Alto', 'Ceja', 'Av. Franco Valle', 3028);
  INSERT INTO SUCURSAL VALUES (4066, 'San Gabriel Achumani', 'Achumani', 'Av. García Lanza', 3028);
  INSERT INTO SUCURSAL VALUES (4067, 'La Francesa Sopocachi', 'Sopocachi', 'Av. Ecuador', 3029);
  INSERT INTO SUCURSAL VALUES (4068, 'La Francesa Obrajes', 'Obrajes', 'Av. 14 de Septiembre', 3029);
  INSERT INTO SUCURSAL VALUES (4069, 'San José Centro', 'Centro', 'Calle Potosí', 3030);
  INSERT INTO SUCURSAL VALUES (4070, 'San José Villa', 'Villa Fátima', 'Plaza Villarroel', 3030);


  -- Farmacias (1:4, porque hay muchas en todos lados)
  INSERT INTO SUCURSAL VALUES (4071, 'Farmacorp Equipetrol', 'Equipetrol', 'Av. San Martín', 3031);
  INSERT INTO SUCURSAL VALUES (4072, 'Farmacorp Plan 3000', 'Plan 3000', 'Plaza Principal', 3031);
  INSERT INTO SUCURSAL VALUES (4073, 'Farmacorp Urubó', 'Urubó', 'Av. Principal', 3031);
  INSERT INTO SUCURSAL VALUES (4074, 'Farmacorp Cristo', 'Norte', 'El Cristo', 3031);
  INSERT INTO SUCURSAL VALUES (4075, 'Chávez Banzer', 'Banzer', 'Km 5', 3032);
  INSERT INTO SUCURSAL VALUES (4076, 'Chávez Centro', 'Centro', 'Plaza 24 de Septiembre', 3032);
  INSERT INTO SUCURSAL VALUES (4077, 'Chávez Villa 1ro', 'Villa 1ro de Mayo', 'Mercado', 3032);
  INSERT INTO SUCURSAL VALUES (4078, 'Chávez Mutualista', 'Mutualista', '3er Anillo', 3032);
  INSERT INTO SUCURSAL VALUES (4079, 'Bolivia Prado', 'Centro', 'El Prado', 3033);
  INSERT INTO SUCURSAL VALUES (4080, 'Bolivia Calacoto', 'Calacoto', 'Calle 21', 3033);
  INSERT INTO SUCURSAL VALUES (4081, 'Telchi Centro', 'Centro', 'Calle Sucre', 3034);
  INSERT INTO SUCURSAL VALUES (4082, 'Telchi Piraí', 'Piraí', 'Av. Piraí', 3034);
  INSERT INTO SUCURSAL VALUES (4083, 'San Agustín', 'Centro', 'Calle Ingavi', 3035);
  INSERT INTO SUCURSAL VALUES (4084, 'Señor de Mayo', 'El Alto', 'Cruce Viacha', 3036);
  INSERT INTO SUCURSAL VALUES (4085, 'La Paz Centro', 'Centro', 'Calle Camacho', 3037);
  INSERT INTO SUCURSAL VALUES (4086, 'Cristo Rey', 'Sopocachi', 'Plaza España', 3038);
  INSERT INTO SUCURSAL VALUES (4087, 'San Pablo', 'Obrajes', 'Calle 17', 3039);
  INSERT INTO SUCURSAL VALUES (4088, 'Lourdes', 'Miraflores', 'Plaza Villarroel', 3040);


  -- Supermercados (1:3 y 1:4)
  INSERT INTO SUCURSAL VALUES (4089, 'Hipermaxi Blanco Galindo', 'Oeste', 'Km 3', 3041);
  INSERT INTO SUCURSAL VALUES (4090, 'Hipermaxi Obrajes', 'Obrajes', 'Calle 17', 3041);
  INSERT INTO SUCURSAL VALUES (4091, 'Hipermaxi Banzer', 'Norte', '7mo Anillo', 3041);
  INSERT INTO SUCURSAL VALUES (4092, 'Hipermaxi Sopocachi', 'Sopocachi', 'Plaza Avaroa', 3041);
  INSERT INTO SUCURSAL VALUES (4093, 'Ketal Megacenter', 'Irpavi', 'Av. Rafael Pabón', 3042);
  INSERT INTO SUCURSAL VALUES (4094, 'Ketal San Miguel', 'San Miguel', 'Av. Montenegro', 3042);
  INSERT INTO SUCURSAL VALUES (4095, 'Ketal Miraflores', 'Miraflores', 'Av. Saavedra', 3042);
  INSERT INTO SUCURSAL VALUES (4096, 'Fidalga Equipetrol', 'Equipetrol', 'Av. San Martín', 3043);
  INSERT INTO SUCURSAL VALUES (4097, 'Fidalga Blacutt', 'Sur', 'Plaza Blacutt', 3043);
  INSERT INTO SUCURSAL VALUES (4098, 'Fidalga Trompillo', 'Trompillo', 'Av. El Trompillo', 3043);
  INSERT INTO SUCURSAL VALUES (4099, 'IC Norte Blanco Galindo', 'Oeste', 'Km 2.5', 3044);
  INSERT INTO SUCURSAL VALUES (4100, 'IC Norte América', 'Norte', 'Av. América', 3044);
  COMMIT;
END;
 




BEGIN
  -- Resto de Supermercados (1:2)
  INSERT INTO SUCURSAL VALUES (4101, 'Tía Centro', 'Centro', 'Calle Velasco', 3045);
  INSERT INTO SUCURSAL VALUES (4102, 'Tía Norte', 'Norte', 'Av. Banzer', 3045);
  INSERT INTO SUCURSAL VALUES (4103, 'SAS Centro', 'Centro', 'Calle 25 de Mayo', 3046);
  INSERT INTO SUCURSAL VALUES (4104, 'SAS Sur', 'Sur', 'Av. Panamericana', 3046);
  INSERT INTO SUCURSAL VALUES (4105, 'Súper Sur Achumani', 'Achumani', 'Calle 16', 3047);
  INSERT INTO SUCURSAL VALUES (4106, 'Súper Sur Calacoto', 'Calacoto', 'Calle 21', 3047);
 
  -- Micromercados (1:2)
  INSERT INTO SUCURSAL VALUES (4107, 'Andy Sopocachi', 'Sopocachi', 'Av. Ecuador', 3048);
  INSERT INTO SUCURSAL VALUES (4108, 'Andy Miraflores', 'Miraflores', 'Av. Busch', 3048);
  INSERT INTO SUCURSAL VALUES (4109, 'El Paso Obrajes', 'Obrajes', 'Av. Hernando Siles', 3049);
  INSERT INTO SUCURSAL VALUES (4110, 'El Paso Centro', 'Centro', 'Calle Sucre', 3049);
  INSERT INTO SUCURSAL VALUES (4111, 'Market 24 7 Equipetrol', 'Equipetrol', 'Canal Isuto', 3050);
  INSERT INTO SUCURSAL VALUES (4112, 'Market 24 7 Urubó', 'Urubó', 'Plaza Principal', 3050);


  -- Pizzerías (Mayormente 1:2 o 1:1)
  INSERT INTO SUCURSAL VALUES (4113, 'Elis Prado', 'Centro', 'El Prado', 3051);
  INSERT INTO SUCURSAL VALUES (4114, 'Elis San Miguel', 'San Miguel', 'Av. Montenegro', 3051);
  INSERT INTO SUCURSAL VALUES (4115, 'Margarita Sopocachi', 'Sopocachi', 'Av. 20 de Octubre', 3052);
  INSERT INTO SUCURSAL VALUES (4116, 'Margarita Sur', 'Calacoto', 'Calle 15', 3052);
  INSERT INTO SUCURSAL VALUES (4117, 'D Italia Centro', 'Centro', 'Plaza del Estudiante', 3053);
  INSERT INTO SUCURSAL VALUES (4118, 'Cozzolisi Miraflores', 'Miraflores', 'Estadio', 3054);
  INSERT INTO SUCURSAL VALUES (4119, 'Cozzolisi Obrajes', 'Obrajes', 'Calle 17', 3054);
  INSERT INTO SUCURSAL VALUES (4120, 'Napoli Equipetrol', 'Equipetrol', 'Av. San Martín', 3055);
  INSERT INTO SUCURSAL VALUES (4121, 'Nápoles Norte', 'Norte', 'Av. Banzer', 3056);
  INSERT INTO SUCURSAL VALUES (4122, 'La Taverna Sur', 'Sur', 'Av. Santos Dumont', 3057);
  INSERT INTO SUCURSAL VALUES (4123, 'La Taverna Centro', 'Centro', 'Plaza 24', 3057);
  INSERT INTO SUCURSAL VALUES (4124, 'Mozzarella Cala Cala', 'Norte', 'Av. Libertador', 3058);
  INSERT INTO SUCURSAL VALUES (4125, 'Mamma Mia Centro', 'Centro', 'Plaza Colón', 3059);
  INSERT INTO SUCURSAL VALUES (4126, 'Roma Sur', 'Sur', 'Av. Ayacucho', 3060);


  -- Chifas y Comida Asiática (1:2 y 1:1)
  INSERT INTO SUCURSAL VALUES (4127, 'Lu Qing Sopocachi', 'Sopocachi', 'Av. Ecuador', 3061);
  INSERT INTO SUCURSAL VALUES (4128, 'Lu Qing Megacenter', 'Irpavi', 'Patio de Comidas', 3061);
  INSERT INTO SUCURSAL VALUES (4129, 'Chifa Rey Centro', 'Centro', 'Calle Potosí', 3062);
  INSERT INTO SUCURSAL VALUES (4130, 'Dragón Equipetrol', 'Equipetrol', 'Canal Isuto', 3063);
  INSERT INTO SUCURSAL VALUES (4131, 'Dragón Banzer', 'Norte', '4to Anillo', 3063);
  INSERT INTO SUCURSAL VALUES (4132, 'Oriental Norte', 'Norte', 'Av. América', 3064);
  INSERT INTO SUCURSAL VALUES (4133, 'Sushi Bar San Miguel', 'San Miguel', 'Av. Montenegro', 3065);
  INSERT INTO SUCURSAL VALUES (4134, 'Sushi Pop Equipetrol', 'Equipetrol', 'Av. San Martín', 3066);
  INSERT INTO SUCURSAL VALUES (4135, 'Kenzo Sopocachi', 'Sopocachi', 'Plaza Avaroa', 3067);
  INSERT INTO SUCURSAL VALUES (4136, 'Kenzo Calacoto', 'Calacoto', 'Calle 21', 3067);
  INSERT INTO SUCURSAL VALUES (4137, 'Miyako Sur', 'Sur', 'Av. Las Américas', 3068);
  INSERT INTO SUCURSAL VALUES (4138, 'Sakura Centro', 'Centro', 'Calle Ayacucho', 3069);
  INSERT INTO SUCURSAL VALUES (4139, 'Wok & Roll Ventura', 'Equipetrol', 'Mall Ventura', 3070);


  -- Heladerías y Postres (1:3 y 1:2)
  INSERT INTO SUCURSAL VALUES (4140, 'Bits Centro', 'Centro', 'Plaza 24 de Septiembre', 3071);
  INSERT INTO SUCURSAL VALUES (4141, 'Bits Ventura', 'Equipetrol', 'Mall Ventura', 3071);
  INSERT INTO SUCURSAL VALUES (4142, 'Bits Norte', 'Norte', 'Cine Center', 3071);
  INSERT INTO SUCURSAL VALUES (4143, 'Vaca Fría San Miguel', 'San Miguel', 'Av. Montenegro', 3072);
  INSERT INTO SUCURSAL VALUES (4144, 'Vaca Fría Sopocachi', 'Sopocachi', 'Plaza Avaroa', 3072);
  INSERT INTO SUCURSAL VALUES (4145, 'Yogen Megacenter', 'Irpavi', 'Patio de Comidas', 3073);
  INSERT INTO SUCURSAL VALUES (4146, 'Splendid Centro', 'Centro', 'Calle Ayacucho', 3074);
  INSERT INTO SUCURSAL VALUES (4147, 'Frigo Norte', 'Norte', 'Av. América', 3075);
  INSERT INTO SUCURSAL VALUES (4148, 'Panda Prado', 'Centro', 'El Prado', 3076);
  INSERT INTO SUCURSAL VALUES (4149, 'Panda Obrajes', 'Obrajes', 'Av. Hernando Siles', 3076);
  INSERT INTO SUCURSAL VALUES (4150, 'Delizia Miraflores', 'Miraflores', 'Estadio', 3077);
  INSERT INTO SUCURSAL VALUES (4151, 'Delizia Ceja', 'El Alto', 'La Ceja', 3077);
  INSERT INTO SUCURSAL VALUES (4152, 'Manolo Prado', 'Centro', 'El Prado', 3078);
  INSERT INTO SUCURSAL VALUES (4153, 'Cinnabon Megacenter', 'Irpavi', 'Patio de Comidas', 3079);
  INSERT INTO SUCURSAL VALUES (4154, 'Cinnabon Ventura', 'Equipetrol', 'Mall Ventura', 3079);
  INSERT INTO SUCURSAL VALUES (4155, 'Donuts Shop Calacoto', 'Calacoto', 'Calle 21', 3080);


  -- Churrasquerías (1:2 y 1:1)
  INSERT INTO SUCURSAL VALUES (4156, 'Palenque Equipetrol', 'Equipetrol', '3er Anillo', 3081);
  INSERT INTO SUCURSAL VALUES (4157, 'Palenque Norte', 'Norte', 'Av. Banzer', 3081);
  INSERT INTO SUCURSAL VALUES (4158, 'Los Hierros Sur', 'Sur', 'Av. Doble Vía', 3082);
  INSERT INTO SUCURSAL VALUES (4159, 'La Tranquera Centro', 'Centro', 'Plaza Principal', 3083);
  INSERT INTO SUCURSAL VALUES (4160, 'Carnes Cortes Norte', 'Norte', 'Av. América', 3084);
  INSERT INTO SUCURSAL VALUES (4161, 'Carnes Cortes Sur', 'Sur', 'Av. Pando', 3084);
  INSERT INTO SUCURSAL VALUES (4162, 'El Buen Gusto', 'Centro', 'Calle Sucre', 3085);
  INSERT INTO SUCURSAL VALUES (4163, 'El Rancho', 'Oeste', 'Blanco Galindo', 3086);
  INSERT INTO SUCURSAL VALUES (4164, 'San Juan', 'Este', 'Av. Villazón', 3087);
  INSERT INTO SUCURSAL VALUES (4165, 'El Fogón Sopocachi', 'Sopocachi', 'Av. 20 de Octubre', 3088);
  INSERT INTO SUCURSAL VALUES (4166, 'La Brasa Miraflores', 'Miraflores', 'Av. Busch', 3089);
  INSERT INTO SUCURSAL VALUES (4167, 'La Brasa Calacoto', 'Calacoto', 'Calle 15', 3089);
  INSERT INTO SUCURSAL VALUES (4168, 'Grill Master Urubó', 'Urubó', 'Puente Urubó', 3090);


  -- Tiendas y Licorerías (1:1, negocios de barrio)
  INSERT INTO SUCURSAL VALUES (4169, 'Licores Baco Equipetrol', 'Equipetrol', 'Calle 7', 3091);
  INSERT INTO SUCURSAL VALUES (4170, 'Licorería 24H Sopocachi', 'Sopocachi', 'Plaza España', 3092);
  INSERT INTO SUCURSAL VALUES (4171, 'Licorería 24H Miraflores', 'Miraflores', 'Estadio', 3092);
  INSERT INTO SUCURSAL VALUES (4172, 'Market Express Banzer', 'Norte', '5to Anillo', 3093);
  INSERT INTO SUCURSAL VALUES (4173, 'Kiosco El Vecino', 'Villa Fátima', 'Plaza Maestro', 3094);
  INSERT INTO SUCURSAL VALUES (4174, 'La Caserita', 'Garita de Lima', 'Mercado', 3095);
  INSERT INTO SUCURSAL VALUES (4175, 'Minimarket La Esquina', 'Obrajes', 'Calle 16', 3096);
  INSERT INTO SUCURSAL VALUES (4176, 'Minimarket Central', 'Centro', 'Calle Murillo', 3097);
  INSERT INTO SUCURSAL VALUES (4177, 'Drugstore La Noche', 'Calacoto', 'San Miguel', 3098);
  INSERT INTO SUCURSAL VALUES (4178, 'Tienda San Pedro', 'San Pedro', 'Plaza San Pedro', 3099);
  INSERT INTO SUCURSAL VALUES (4179, 'Tienda El Sol', 'Cotahuma', 'Av. Buenos Aires', 3100);


  -- Rellenamos con algunas sucursales más para llegar a las 200 exactas
  INSERT INTO SUCURSAL VALUES (4180, 'Chriss Sur', 'Sur', 'Doble vía Guardia', 3002);
  INSERT INTO SUCURSAL VALUES (4181, 'Kingdom Sur', 'Sur', 'Calle 21', 3004);
  INSERT INTO SUCURSAL VALUES (4182, 'Burger King Sur', 'Calacoto', 'Plaza Humboldt', 3009);
  INSERT INTO SUCURSAL VALUES (4183, 'Typica Achumani', 'Achumani', 'Av. García Lanza', 3016);
  INSERT INTO SUCURSAL VALUES (4184, 'Wistupiku San Miguel', 'San Miguel', 'Montenegro', 3021);
  INSERT INTO SUCURSAL VALUES (4185, 'Paceñas Irpavi', 'Irpavi', 'Av. Ovando', 3023);
  INSERT INTO SUCURSAL VALUES (4186, 'Farmacorp Miraflores', 'Miraflores', 'Av. Saavedra', 3031);
  INSERT INTO SUCURSAL VALUES (4187, 'Chávez Sur', 'Sur', 'Av. Santos Dumont', 3032);
  INSERT INTO SUCURSAL VALUES (4188, 'Bolivia Sopocachi', 'Sopocachi', 'Plaza España', 3033);
  INSERT INTO SUCURSAL VALUES (4189, 'Telchi Equipetrol', 'Equipetrol', 'San Martín', 3034);
  INSERT INTO SUCURSAL VALUES (4190, 'Hipermaxi Sur', 'Sur', 'Doble Vía Guardia', 3041);
  INSERT INTO SUCURSAL VALUES (4191, 'Ketal Sopocachi', 'Sopocachi', 'Plaza España', 3042);
  INSERT INTO SUCURSAL VALUES (4192, 'Fidalga Norte', 'Norte', 'Av. Banzer', 3043);
  INSERT INTO SUCURSAL VALUES (4193, 'IC Norte Sur', 'Sur', 'Av. Panamericana', 3044);
  INSERT INTO SUCURSAL VALUES (4194, 'Elis Norte', 'Norte', 'Cine Center', 3051);
  INSERT INTO SUCURSAL VALUES (4195, 'Lu Qing Sur', 'Calacoto', 'Calle 15', 3061);
  INSERT INTO SUCURSAL VALUES (4196, 'Sushi Pop Sur', 'Sur', 'Las Américas', 3066);
  INSERT INTO SUCURSAL VALUES (4197, 'Bits Sur', 'Sur', 'Plaza Blacutt', 3071);
  INSERT INTO SUCURSAL VALUES (4198, 'Vaca Fría Norte', 'Norte', 'Cine Center', 3072);
  INSERT INTO SUCURSAL VALUES (4199, 'Panda Norte', 'Norte', 'Av. América', 3076);
  INSERT INTO SUCURSAL VALUES (4200, 'Palenque Sur', 'Sur', 'Av. Doble Vía', 3081);
  COMMIT;
END;
 

--PROMOCION
BEGIN
  -- Sucursal 4001 (Copacabana Prado) - 4 promos (1:4)
  INSERT INTO PROMOCION VALUES (5001, 'Combo Familiar 2x1', '2x1', 50.00, 'Vencida', TO_DATE('2025-11-01', 'YYYY-MM-DD'), TO_DATE('2025-11-30', 'YYYY-MM-DD'), 4001);
  INSERT INTO PROMOCION VALUES (5002, 'Descuento Carnaval Paceño', 'Descuento', 15.00, 'Vencida', TO_DATE('2026-02-10', 'YYYY-MM-DD'), TO_DATE('2026-02-20', 'YYYY-MM-DD'), 4001);
  INSERT INTO PROMOCION VALUES (5003, 'Almuerzo de Locura', 'Combo', 20.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4001);
  INSERT INTO PROMOCION VALUES (5004, 'Envío Gratis Zona Central', 'Envío Gratis', 0.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4001);


  -- Sucursal 4002 (Copacabana Miraflores) - 3 promos (1:3)
  INSERT INTO PROMOCION VALUES (5005, 'Promo Día del Estudiante', 'Descuento', 25.00, 'Vencida', TO_DATE('2025-09-15', 'YYYY-MM-DD'), TO_DATE('2025-09-25', 'YYYY-MM-DD'), 4002);
  INSERT INTO PROMOCION VALUES (5006, 'Combo Clásico + Gaseosa', 'Combo', 10.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4002);
  INSERT INTO PROMOCION VALUES (5007, 'Finde 2x1 en Helados', '2x1', 50.00, 'Inactiva', TO_DATE('2026-05-01', 'YYYY-MM-DD'), TO_DATE('2026-05-05', 'YYYY-MM-DD'), 4002);


  -- Sucursal 4003 (Copacabana Sur) - 2 promos (1:2)
  INSERT INTO PROMOCION VALUES (5008, 'Mes Aniversario', 'Descuento', 30.00, 'Vencida', TO_DATE('2025-07-01', 'YYYY-MM-DD'), TO_DATE('2025-07-31', 'YYYY-MM-DD'), 4003);
  INSERT INTO PROMOCION VALUES (5009, 'Mega Combo Sur', 'Combo', 15.00, 'Activa', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-05-20', 'YYYY-MM-DD'), 4003);


  -- Sucursal 4005 (Chriss Equipetrol) - 3 promos (1:3)
  INSERT INTO PROMOCION VALUES (5010, 'Combo Carnavalero', 'Combo', 20.00, 'Vencida', TO_DATE('2026-02-15', 'YYYY-MM-DD'), TO_DATE('2026-02-28', 'YYYY-MM-DD'), 4005);
  INSERT INTO PROMOCION VALUES (5011, 'Viernes de Pipocas', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4005);
  INSERT INTO PROMOCION VALUES (5012, 'Envío Gratis Equipetrol', 'Envío Gratis', 0.00, 'Activa', TO_DATE('2026-04-25', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4005);


  -- Sucursal 4006 y 4007 (1 promo c u) - (1:1)
  INSERT INTO PROMOCION VALUES (5013, 'Descuento Plan 3000', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4006);
  INSERT INTO PROMOCION VALUES (5014, 'Almuerzo Ejecutivo', 'Combo', 15.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4007);


  -- Sucursales Toby (4008 a 4010) - (1:2)
  INSERT INTO PROMOCION VALUES (5015, 'Toby Doble', '2x1', 50.00, 'Vencida', TO_DATE('2025-12-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'), 4008);
  INSERT INTO PROMOCION VALUES (5016, 'Navidad en Toby', 'Descuento', 25.00, 'Vencida', TO_DATE('2025-12-15', 'YYYY-MM-DD'), TO_DATE('2025-12-25', 'YYYY-MM-DD'), 4008);
  INSERT INTO PROMOCION VALUES (5017, 'Promo Estudiante', 'Descuento', 15.00, 'Activa', TO_DATE('2026-03-01', 'YYYY-MM-DD'), TO_DATE('2026-05-31', 'YYYY-MM-DD'), 4009);
  INSERT INTO PROMOCION VALUES (5018, 'Jueves de Toby', 'Combo', 20.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4010);


  -- Sucursales Kingdom (4011, 4012)
  INSERT INTO PROMOCION VALUES (5019, 'Kingdom 2x1', '2x1', 50.00, 'Activa', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-04-28', 'YYYY-MM-DD'), 4011);
  INSERT INTO PROMOCION VALUES (5020, 'Finde Familiar', 'Combo', 20.00, 'Inactiva', TO_DATE('2026-05-01', 'YYYY-MM-DD'), TO_DATE('2026-05-31', 'YYYY-MM-DD'), 4011);
  INSERT INTO PROMOCION VALUES (5021, 'Descuento Obrajes', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4012);


  -- Panchita (4015 a 4018) - Algunas con 3, otras con 1
  INSERT INTO PROMOCION VALUES (5022, 'Panchita Aniversario CBBA', 'Descuento', 30.00, 'Vencida', TO_DATE('2025-09-01', 'YYYY-MM-DD'), TO_DATE('2025-09-30', 'YYYY-MM-DD'), 4015);
  INSERT INTO PROMOCION VALUES (5023, 'Combo Trancapecho', 'Combo', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4015);
  INSERT INTO PROMOCION VALUES (5024, 'Envío Gratis Norte', 'Envío Gratis', 0.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4015);
  INSERT INTO PROMOCION VALUES (5025, '2x1 Quillacollo', '2x1', 50.00, 'Activa', TO_DATE('2026-04-25', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4016);
  INSERT INTO PROMOCION VALUES (5026, 'Combo Panchita', 'Combo', 15.00, 'Inactiva', TO_DATE('2026-06-01', 'YYYY-MM-DD'), TO_DATE('2026-06-30', 'YYYY-MM-DD'), 4017);
  INSERT INTO PROMOCION VALUES (5027, 'Día del Peatón', 'Descuento', 20.00, 'Vencida', TO_DATE('2025-09-01', 'YYYY-MM-DD'), TO_DATE('2025-09-05', 'YYYY-MM-DD'), 4018);


  -- Burger King (4023 a 4025)
  INSERT INTO PROMOCION VALUES (5028, 'Whopper 2x1', '2x1', 50.00, 'Vencida', TO_DATE('2025-11-20', 'YYYY-MM-DD'), TO_DATE('2025-11-30', 'YYYY-MM-DD'), 4023);
  INSERT INTO PROMOCION VALUES (5029, 'Combo Rey', 'Combo', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4023);
  INSERT INTO PROMOCION VALUES (5030, 'Descuento Mega', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4024);
  INSERT INTO PROMOCION VALUES (5031, 'Cine + Burger', 'Combo', 25.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4025);


  -- McDonald's (4026 a 4028)
  INSERT INTO PROMOCION VALUES (5032, 'Big Mac a Mitad', 'Descuento', 50.00, 'Vencida', TO_DATE('2025-10-10', 'YYYY-MM-DD'), TO_DATE('2025-10-20', 'YYYY-MM-DD'), 4026);
  INSERT INTO PROMOCION VALUES (5033, 'Cajita Feliz + Regalo', 'Regalo', 0.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4026);
  INSERT INTO PROMOCION VALUES (5034, 'McCombo Urubó', 'Combo', 15.00, 'Activa', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-05-20', 'YYYY-MM-DD'), 4027);
  INSERT INTO PROMOCION VALUES (5035, 'Desayuno Ventura', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4028);


  -- Casa del Camba (4029, 4030)
  INSERT INTO PROMOCION VALUES (5036, 'Majadito 2x1', '2x1', 50.00, 'Vencida', TO_DATE('2025-09-20', 'YYYY-MM-DD'), TO_DATE('2025-09-30', 'YYYY-MM-DD'), 4029);
  INSERT INTO PROMOCION VALUES (5037, 'Finde Familiar Camba', 'Combo', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4029);
  INSERT INTO PROMOCION VALUES (5038, 'Almuerzo 2do Anillo', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4030);


  -- Jardín de Asia (4033, 4034)
  INSERT INTO PROMOCION VALUES (5039, 'Sushi Night', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4033);
  INSERT INTO PROMOCION VALUES (5040, 'Menú Degustación', 'Combo', 15.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4034);


  -- Cafeterías Typica (4039 a 4041)
  INSERT INTO PROMOCION VALUES (5041, 'Café + Pastelito', 'Combo', 15.00, 'Vencida', TO_DATE('2025-11-01', 'YYYY-MM-DD'), TO_DATE('2025-11-30', 'YYYY-MM-DD'), 4039);
  INSERT INTO PROMOCION VALUES (5042, 'Tardes de Typica', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4039);
  INSERT INTO PROMOCION VALUES (5043, '2x1 Cappuccino', '2x1', 50.00, 'Activa', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4040);
  INSERT INTO PROMOCION VALUES (5044, 'Desayuno Equipetrol', 'Combo', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4041);


  -- Alexander Coffee (4042 a 4044)
  INSERT INTO PROMOCION VALUES (5045, 'Promo Invierno', 'Descuento', 20.00, 'Vencida', TO_DATE('2025-06-01', 'YYYY-MM-DD'), TO_DATE('2025-07-31', 'YYYY-MM-DD'), 4042);
  INSERT INTO PROMOCION VALUES (5046, 'Frappé 2x1', '2x1', 50.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4042);
  INSERT INTO PROMOCION VALUES (5047, 'Torta Especial', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4043);
  INSERT INTO PROMOCION VALUES (5048, 'Viajero Frecuente', 'Descuento', 10.00, 'Activa', TO_DATE('2026-01-01', 'YYYY-MM-DD'), TO_DATE('2026-12-31', 'YYYY-MM-DD'), 4044);


  -- Wistupiku (4051 a 4053)
  INSERT INTO PROMOCION VALUES (5049, 'Empanadas 5x4', 'Regalo', 20.00, 'Vencida', TO_DATE('2025-08-01', 'YYYY-MM-DD'), TO_DATE('2025-08-31', 'YYYY-MM-DD'), 4051);
  INSERT INTO PROMOCION VALUES (5050, 'Promo Desayuno Cbba', 'Combo', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4052);
  INSERT INTO PROMOCION VALUES (5051, 'Combo Clásico Stadium', 'Combo', 10.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4053);


  -- Salteñas (4054 a 4059)
  INSERT INTO PROMOCION VALUES (5052, 'Salteñas 3x2', '2x1', 33.33, 'Vencida', TO_DATE('2025-10-01', 'YYYY-MM-DD'), TO_DATE('2025-10-31', 'YYYY-MM-DD'), 4054);
  INSERT INTO PROMOCION VALUES (5053, 'Mañana de Salteñas', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4055);
  INSERT INTO PROMOCION VALUES (5054, 'Combo Paceña + Refresco', 'Combo', 15.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4056);
  INSERT INTO PROMOCION VALUES (5055, 'Descuento Miraflores', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-05-20', 'YYYY-MM-DD'), 4057);
  INSERT INTO PROMOCION VALUES (5056, 'Promo Potosina', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4058);


  -- Relleno general bloque 1 (Distribuyendo 1:1, 1:2)
  INSERT INTO PROMOCION VALUES (5057, 'Tardes de Café', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4045);
  INSERT INTO PROMOCION VALUES (5058, 'Promo Vainilla', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4047);
  INSERT INTO PROMOCION VALUES (5059, 'Dumbo Kids', 'Regalo', 0.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4049);
  INSERT INTO PROMOCION VALUES (5060, 'Día de la Familia', 'Descuento', 25.00, 'Inactiva', TO_DATE('2026-05-10', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4050);
  INSERT INTO PROMOCION VALUES (5061, 'Combo Hornito', 'Combo', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4060);
  INSERT INTO PROMOCION VALUES (5062, 'Descuento Santa Clara', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4062);
  INSERT INTO PROMOCION VALUES (5063, 'Promo Panadería', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4063);
  INSERT INTO PROMOCION VALUES (5064, 'Desayuno San Gabriel', 'Combo', 15.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4065);
  INSERT INTO PROMOCION VALUES (5065, 'Mes Francesa', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4067);
  INSERT INTO PROMOCION VALUES (5066, 'Promo San José', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4069);
 
  -- Farmacias (4071 a 4088)
  INSERT INTO PROMOCION VALUES (5067, 'Vitaminas 2x1', '2x1', 50.00, 'Vencida', TO_DATE('2025-06-01', 'YYYY-MM-DD'), TO_DATE('2025-06-30', 'YYYY-MM-DD'), 4071);
  INSERT INTO PROMOCION VALUES (5068, 'Día de la Salud', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-07', 'YYYY-MM-DD'), TO_DATE('2026-04-14', 'YYYY-MM-DD'), 4071);
  INSERT INTO PROMOCION VALUES (5069, 'Cuidado Personal', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4072);
  INSERT INTO PROMOCION VALUES (5070, 'Descuento Pañales', 'Descuento', 25.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4073);
  INSERT INTO PROMOCION VALUES (5071, 'Promo Cristo', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4074);
  INSERT INTO PROMOCION VALUES (5072, 'Mes Aniversario Chávez', 'Descuento', 30.00, 'Vencida', TO_DATE('2025-08-01', 'YYYY-MM-DD'), TO_DATE('2025-08-31', 'YYYY-MM-DD'), 4075);
  INSERT INTO PROMOCION VALUES (5073, 'Descuento Centro', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4076);
  INSERT INTO PROMOCION VALUES (5074, 'Cuidado Capilar', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4077);
  INSERT INTO PROMOCION VALUES (5075, 'Promo Bolivia', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4079);
  INSERT INTO PROMOCION VALUES (5076, 'Día de la Madre Farmacia', 'Descuento', 25.00, 'Inactiva', TO_DATE('2026-05-20', 'YYYY-MM-DD'), TO_DATE('2026-05-31', 'YYYY-MM-DD'), 4080);
  INSERT INTO PROMOCION VALUES (5077, 'Descuento Telchi', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4081);
  INSERT INTO PROMOCION VALUES (5078, 'Promo San Agustín', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4083);
  INSERT INTO PROMOCION VALUES (5079, 'Cuidado Piel', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4085);
  INSERT INTO PROMOCION VALUES (5080, 'Descuento Cristo Rey', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4086);
  INSERT INTO PROMOCION VALUES (5081, 'Promo San Pablo', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4087);
  INSERT INTO PROMOCION VALUES (5082, 'Mes Saludable Lourdes', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4088);


  -- Supermercados (4089 a 4100)
  INSERT INTO PROMOCION VALUES (5083, 'Día de la Carne', 'Descuento', 15.00, 'Vencida', TO_DATE('2025-10-15', 'YYYY-MM-DD'), TO_DATE('2025-10-15', 'YYYY-MM-DD'), 4089);
  INSERT INTO PROMOCION VALUES (5084, 'Finde Hiper', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-24', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 4089);
  INSERT INTO PROMOCION VALUES (5085, 'Día de la Verdura', 'Descuento', 25.00, 'Activa', TO_DATE('2026-04-22', 'YYYY-MM-DD'), TO_DATE('2026-04-22', 'YYYY-MM-DD'), 4090);
  INSERT INTO PROMOCION VALUES (5086, 'Promo Limpieza', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4091);
  INSERT INTO PROMOCION VALUES (5087, 'Mes Aniversario Ketal', 'Descuento', 30.00, 'Vencida', TO_DATE('2025-11-01', 'YYYY-MM-DD'), TO_DATE('2025-11-30', 'YYYY-MM-DD'), 4093);
  INSERT INTO PROMOCION VALUES (5088, 'Finde Ketal', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-24', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 4093);
  INSERT INTO PROMOCION VALUES (5089, 'Día San Miguel', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4094);
  INSERT INTO PROMOCION VALUES (5090, 'Promo Miraflores', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4095);
  INSERT INTO PROMOCION VALUES (5091, 'Día Fidalga', 'Descuento', 20.00, 'Vencida', TO_DATE('2025-12-20', 'YYYY-MM-DD'), TO_DATE('2025-12-24', 'YYYY-MM-DD'), 4096);
  INSERT INTO PROMOCION VALUES (5092, 'Descuento Equipetrol', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4096);
  INSERT INTO PROMOCION VALUES (5093, 'Promo Blacutt', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4097);
  INSERT INTO PROMOCION VALUES (5094, 'Descuento Trompillo', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-05-20', 'YYYY-MM-DD'), 4098);
  INSERT INTO PROMOCION VALUES (5095, 'Finde IC Norte', 'Descuento', 25.00, 'Vencida', TO_DATE('2025-08-15', 'YYYY-MM-DD'), TO_DATE('2025-08-17', 'YYYY-MM-DD'), 4099);
  INSERT INTO PROMOCION VALUES (5096, 'Día de la Fruta', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-23', 'YYYY-MM-DD'), TO_DATE('2026-04-23', 'YYYY-MM-DD'), 4099);
  INSERT INTO PROMOCION VALUES (5097, 'Promo Limpieza Norte', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4100);
  INSERT INTO PROMOCION VALUES (5098, 'Día de la Madre Ketal', 'Descuento', 25.00, 'Inactiva', TO_DATE('2026-05-25', 'YYYY-MM-DD'), TO_DATE('2026-05-27', 'YYYY-MM-DD'), 4093);
  INSERT INTO PROMOCION VALUES (5099, '2x1 Lácteos', '2x1', 50.00, 'Activa', TO_DATE('2026-04-27', 'YYYY-MM-DD'), TO_DATE('2026-04-29', 'YYYY-MM-DD'), 4089);
  INSERT INTO PROMOCION VALUES (5100, 'Descuento Express', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-28', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4100);


  COMMIT;
END;
 


BEGIN
  -- Supermercados restantes (4101 a 4106)
  INSERT INTO PROMOCION VALUES (5101, 'Promo Tía Centro', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4101);
  INSERT INTO PROMOCION VALUES (5102, 'Descuento Tía Norte', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4102);
  INSERT INTO PROMOCION VALUES (5103, 'SAS Finde', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-24', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 4103);
  INSERT INTO PROMOCION VALUES (5104, 'Día SAS', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4104);
  INSERT INTO PROMOCION VALUES (5105, 'Súper Sur Achumani', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4105);
  INSERT INTO PROMOCION VALUES (5106, 'Mes Aniversario Sur', 'Descuento', 25.00, 'Inactiva', TO_DATE('2026-06-01', 'YYYY-MM-DD'), TO_DATE('2026-06-30', 'YYYY-MM-DD'), 4106);


  -- Micromercados y Tiendas (1 promo por sucursal)
  INSERT INTO PROMOCION VALUES (5107, 'Promo Bebidas Andy', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4107);
  INSERT INTO PROMOCION VALUES (5108, 'Descuento Snacks', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4108);
  INSERT INTO PROMOCION VALUES (5109, 'Paso Express', 'Envío Gratis', 0.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4109);
  INSERT INTO PROMOCION VALUES (5110, 'Noche 24 7', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4111);


  -- Pizzerías (Varias promos)
  INSERT INTO PROMOCION VALUES (5111, 'Martes 2x1 Elis', '2x1', 50.00, 'Vencida', TO_DATE('2025-10-07', 'YYYY-MM-DD'), TO_DATE('2025-10-28', 'YYYY-MM-DD'), 4113);
  INSERT INTO PROMOCION VALUES (5112, 'Combo Familiar Elis', 'Combo', 20.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4113);
  INSERT INTO PROMOCION VALUES (5113, 'Promo San Miguel', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4114);
  INSERT INTO PROMOCION VALUES (5114, 'Margarita Jueves', 'Descuento', 25.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4115);
  INSERT INTO PROMOCION VALUES (5115, 'Combo Pareja Sur', 'Combo', 15.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4116);
  INSERT INTO PROMOCION VALUES (5116, 'D Italia Finde', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-24', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 4117);
  INSERT INTO PROMOCION VALUES (5117, 'Cozzolisi 2x1', '2x1', 50.00, 'Activa', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4118);
  INSERT INTO PROMOCION VALUES (5118, 'Descuento Obrajes', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4119);
  INSERT INTO PROMOCION VALUES (5119, 'Napoli Equipetrol', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4120);
  INSERT INTO PROMOCION VALUES (5120, 'Taverna Noche', 'Descuento', 20.00, 'Vencida', TO_DATE('2025-11-01', 'YYYY-MM-DD'), TO_DATE('2025-11-30', 'YYYY-MM-DD'), 4122);
  INSERT INTO PROMOCION VALUES (5121, 'Taverna Almuerzo', 'Combo', 15.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4122);
  INSERT INTO PROMOCION VALUES (5122, 'Mamma Mia Centro', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4125);
  INSERT INTO PROMOCION VALUES (5123, 'Roma Promo Sur', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4126);


  -- Chifas y Comida Asiática
  INSERT INTO PROMOCION VALUES (5124, 'Combo Primavera', 'Combo', 15.00, 'Vencida', TO_DATE('2025-09-21', 'YYYY-MM-DD'), TO_DATE('2025-09-30', 'YYYY-MM-DD'), 4127);
  INSERT INTO PROMOCION VALUES (5125, 'Sopocachi Lu Qing', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4127);
  INSERT INTO PROMOCION VALUES (5126, 'Mega Dragón', 'Combo', 20.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4130);
  INSERT INTO PROMOCION VALUES (5127, 'Sushi 3x2 San Miguel', '2x1', 33.33, 'Vencida', TO_DATE('2025-12-01', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'), 4133);
  INSERT INTO PROMOCION VALUES (5128, 'Noche de Sushi', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4133);
  INSERT INTO PROMOCION VALUES (5129, 'Pop Equipetrol', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4134);
  INSERT INTO PROMOCION VALUES (5130, 'Kenzo Sopocachi', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4135);
  INSERT INTO PROMOCION VALUES (5131, 'Wok & Roll Finde', 'Combo', 20.00, 'Activa', TO_DATE('2026-04-24', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 4139);


  -- Heladerías
  INSERT INTO PROMOCION VALUES (5132, 'Bits Finde Centro', 'Descuento', 15.00, 'Vencida', TO_DATE('2025-11-15', 'YYYY-MM-DD'), TO_DATE('2025-11-17', 'YYYY-MM-DD'), 4140);
  INSERT INTO PROMOCION VALUES (5133, 'Bits Ventura', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4141);
  INSERT INTO PROMOCION VALUES (5134, 'Día del Niño Vaca Fría', 'Regalo', 0.00, 'Vencida', TO_DATE('2026-04-12', 'YYYY-MM-DD'), TO_DATE('2026-04-12', 'YYYY-MM-DD'), 4143);
  INSERT INTO PROMOCION VALUES (5135, 'Promo San Miguel Helado', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4143);
  INSERT INTO PROMOCION VALUES (5136, 'Yogen 2x1', '2x1', 50.00, 'Activa', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4145);
  INSERT INTO PROMOCION VALUES (5137, 'Splendid Tradición', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4146);
  INSERT INTO PROMOCION VALUES (5138, 'Frigo Norte', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4147);
  INSERT INTO PROMOCION VALUES (5139, 'Panda Kids', 'Combo', 20.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4148);
  INSERT INTO PROMOCION VALUES (5140, 'Delizia Miraflores', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4150);
  INSERT INTO PROMOCION VALUES (5141, 'Churros 2x1 Prado', '2x1', 50.00, 'Activa', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4152);
  INSERT INTO PROMOCION VALUES (5142, 'Cinnabon Mega', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4153);
  INSERT INTO PROMOCION VALUES (5143, 'Donuts Calacoto', 'Combo', 20.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4155);


  -- Churrasquerías
  INSERT INTO PROMOCION VALUES (5144, 'Jueves Parrillero', 'Descuento', 20.00, 'Vencida', TO_DATE('2025-10-02', 'YYYY-MM-DD'), TO_DATE('2025-10-30', 'YYYY-MM-DD'), 4156);
  INSERT INTO PROMOCION VALUES (5145, 'Palenque Equipetrol', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4156);
  INSERT INTO PROMOCION VALUES (5146, 'Finde Los Hierros', 'Combo', 25.00, 'Activa', TO_DATE('2026-04-24', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 4158);
  INSERT INTO PROMOCION VALUES (5147, 'Tranquera Centro', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4159);
  INSERT INTO PROMOCION VALUES (5148, 'Cortes Especiales', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4160);
  INSERT INTO PROMOCION VALUES (5149, 'El Buen Gusto', 'Combo', 20.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4162);
  INSERT INTO PROMOCION VALUES (5150, 'Rancho Familiar', 'Combo', 15.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4163);
  INSERT INTO PROMOCION VALUES (5151, 'Día del Trabajador Asado', 'Descuento', 25.00, 'Inactiva', TO_DATE('2026-05-01', 'YYYY-MM-DD'), TO_DATE('2026-05-02', 'YYYY-MM-DD'), 4165);
  INSERT INTO PROMOCION VALUES (5152, 'Brasa Miraflores', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4166);
  INSERT INTO PROMOCION VALUES (5153, 'Grill Urubó', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4168);


  -- Licorerías y Tiendas de Barrio
  INSERT INTO PROMOCION VALUES (5154, 'Promo Fin de Año', 'Descuento', 15.00, 'Vencida', TO_DATE('2025-12-25', 'YYYY-MM-DD'), TO_DATE('2025-12-31', 'YYYY-MM-DD'), 4169);
  INSERT INTO PROMOCION VALUES (5155, 'Baco Finde', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-24', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 4169);
  INSERT INTO PROMOCION VALUES (5156, 'Promo Nocturna', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4170);
  INSERT INTO PROMOCION VALUES (5157, 'Vecino Express', 'Envío Gratis', 0.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4173);
  INSERT INTO PROMOCION VALUES (5158, 'Caserita Finde', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-24', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 4174);
  INSERT INTO PROMOCION VALUES (5159, 'Promo Obrajes', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4175);
  INSERT INTO PROMOCION VALUES (5160, 'Drugstore Calacoto', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4177);
  INSERT INTO PROMOCION VALUES (5161, 'San Pedro Promo', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4178);


  -- Rellenamos con las sucursales del final (4180 a 4200) para llegar a las 200
  INSERT INTO PROMOCION VALUES (5162, 'Chriss Sur', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4180);
  INSERT INTO PROMOCION VALUES (5163, 'Kingdom Sur 2x1', '2x1', 50.00, 'Activa', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4181);
  INSERT INTO PROMOCION VALUES (5164, 'BK Sur', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4182);
  INSERT INTO PROMOCION VALUES (5165, 'Typica Achumani', 'Combo', 20.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4183);
  INSERT INTO PROMOCION VALUES (5166, 'Wistupiku San Miguel', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4184);
  INSERT INTO PROMOCION VALUES (5167, 'Paceñas Irpavi', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4185);
  INSERT INTO PROMOCION VALUES (5168, 'Farmacorp Miraflores', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4186);
  INSERT INTO PROMOCION VALUES (5169, 'Chávez Sur Promo', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4187);
  INSERT INTO PROMOCION VALUES (5170, 'Bolivia Sopocachi', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4188);
  INSERT INTO PROMOCION VALUES (5171, 'Telchi Equipetrol', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4189);
  INSERT INTO PROMOCION VALUES (5172, 'Hipermaxi Sur', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4190);
  INSERT INTO PROMOCION VALUES (5173, 'Ketal Sopocachi', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4191);
  INSERT INTO PROMOCION VALUES (5174, 'Fidalga Norte', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4192);
  INSERT INTO PROMOCION VALUES (5175, 'IC Norte Sur', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4193);
  INSERT INTO PROMOCION VALUES (5176, 'Elis Norte', 'Combo', 25.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4194);
  INSERT INTO PROMOCION VALUES (5177, 'Lu Qing Sur', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4195);
  INSERT INTO PROMOCION VALUES (5178, 'Sushi Pop Sur', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4196);
  INSERT INTO PROMOCION VALUES (5179, 'Bits Sur', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4197);
  INSERT INTO PROMOCION VALUES (5180, 'Vaca Fría Norte', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 4198);
  INSERT INTO PROMOCION VALUES (5181, 'Panda Norte', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4199);
  INSERT INTO PROMOCION VALUES (5182, 'Palenque Sur', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4200);


  -- Extras adicionales en sucursales principales para asegurar dinamismo
  INSERT INTO PROMOCION VALUES (5183, 'Copacabana Sur Finde', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-24', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 4003);
  INSERT INTO PROMOCION VALUES (5184, 'Burger King Sur Finde', 'Combo', 20.00, 'Activa', TO_DATE('2026-04-24', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 4182);
  INSERT INTO PROMOCION VALUES (5185, 'Farmacorp Sur 2x1', '2x1', 50.00, 'Inactiva', TO_DATE('2026-06-01', 'YYYY-MM-DD'), TO_DATE('2026-06-15', 'YYYY-MM-DD'), 4071);
  INSERT INTO PROMOCION VALUES (5186, 'Dumbo Sur Kids', 'Regalo', 0.00, 'Activa', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4050);
  INSERT INTO PROMOCION VALUES (5187, 'Hipermaxi Sur Carnes', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-22', 'YYYY-MM-DD'), TO_DATE('2026-04-25', 'YYYY-MM-DD'), 4190);
  INSERT INTO PROMOCION VALUES (5188, 'Ketal Sur Verduras', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-04-22', 'YYYY-MM-DD'), 4191);
  INSERT INTO PROMOCION VALUES (5189, 'Fidalga Norte Lácteos', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-04-18', 'YYYY-MM-DD'), 4192);
  INSERT INTO PROMOCION VALUES (5190, 'IC Norte Sur Limpieza', 'Descuento', 25.00, 'Activa', TO_DATE('2026-04-26', 'YYYY-MM-DD'), TO_DATE('2026-04-28', 'YYYY-MM-DD'), 4193);
  INSERT INTO PROMOCION VALUES (5191, 'Elis Norte Pizzas', '2x1', 50.00, 'Activa', TO_DATE('2026-04-28', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4194);
  INSERT INTO PROMOCION VALUES (5192, 'Lu Qing Sur Buffet', 'Descuento', 15.00, 'Inactiva', TO_DATE('2026-05-01', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 4195);
  INSERT INTO PROMOCION VALUES (5193, 'Sushi Pop Sur 3x2', '2x1', 33.33, 'Activa', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4196);
  INSERT INTO PROMOCION VALUES (5194, 'Bits Sur Helados', 'Descuento', 10.00, 'Activa', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-04-25', 'YYYY-MM-DD'), 4197);
  INSERT INTO PROMOCION VALUES (5195, 'Vaca Fría Norte 2x1', '2x1', 50.00, 'Inactiva', TO_DATE('2026-05-10', 'YYYY-MM-DD'), TO_DATE('2026-05-20', 'YYYY-MM-DD'), 4198);
  INSERT INTO PROMOCION VALUES (5196, 'Panda Norte Postres', 'Descuento', 15.00, 'Activa', TO_DATE('2026-04-22', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 4199);
  INSERT INTO PROMOCION VALUES (5197, 'Palenque Sur Asado', 'Descuento', 20.00, 'Activa', TO_DATE('2026-04-25', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 4200);
  INSERT INTO PROMOCION VALUES (5198, 'Copacabana Prado Extra', 'Descuento', 10.00, 'Inactiva', TO_DATE('2026-06-01', 'YYYY-MM-DD'), TO_DATE('2026-06-30', 'YYYY-MM-DD'), 4001);
  INSERT INTO PROMOCION VALUES (5199, 'Chriss Equipetrol Extra', 'Descuento', 15.00, 'Inactiva', TO_DATE('2026-06-15', 'YYYY-MM-DD'), TO_DATE('2026-06-30', 'YYYY-MM-DD'), 4005);
  INSERT INTO PROMOCION VALUES (5200, 'Toby Cine Center Extra', 'Descuento', 20.00, 'Inactiva', TO_DATE('2026-07-01', 'YYYY-MM-DD'), TO_DATE('2026-07-15', 'YYYY-MM-DD'), 4008);


  COMMIT;
END;
 



--PRODUCTO
BEGIN
  -- Pollos y Comida Rápida
  INSERT INTO PRODUCTO VALUES (6001, 'Combo Familiar de Pollo', '8 presas de pollo, porción familiar de papas y arroz, 1 gaseosa 2L', 110.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6002, 'Combo Personal Pollo', '2 presas de pollo, papas fritas, arroz y refresco', 35.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6003, 'Pipocas de Pollo', 'Porción mediana de pipocas de pollo con papas fritas', 25.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6004, 'Hamburguesa Clásica', 'Carne de res, lechuga, tomate, queso y salsas', 20.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6005, 'Doble Hamburguesa con Queso', 'Doble carne, doble queso cheddar, tocino y salsas especiales', 35.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6006, 'Combo Whopper', 'Hamburguesa Whopper, papas medianas y gaseosa', 45.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6007, 'Cajita Feliz Burger', 'Hamburguesa pequeña, papas pequeñas, jugo y juguete', 30.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6008, 'Nuggets de Pollo x10', '10 piezas de nuggets de pollo con salsa a elección', 22.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6009, 'Papas Fritas Medianas', 'Porción tradicional de papas fritas crujientes', 12.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6010, 'Aros de Cebolla', 'Porción de 8 aros de cebolla empanizados', 15.00, 'Agotado');
  
  -- Comida Tradicional (Salteñas, Empanadas, Platos típicos)
  INSERT INTO PRODUCTO VALUES (6011, 'Salteña de Carne Fricase', 'Salteña tradicional caldoza con carne de res picada', 8.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6012, 'Salteña de Pollo Dulce', 'Salteña de pollo con un toque dulce tradicional paceño', 8.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6013, 'Salteña de Pollo Picante', 'Salteña de pollo con ají amarillo', 8.50, 'Activo');
  INSERT INTO PRODUCTO VALUES (6014, 'Salteña de Hoja de Carne', 'Salteña masa hojaldre rellena de carne', 9.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6015, 'Empanada de Queso al Horno', 'Empanada tradicional crujiente con queso fundido', 7.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6016, 'Empanada Santa Clara', 'Empanada típica con relleno especial de la casa', 9.00, 'Inactivo');
  INSERT INTO PRODUCTO VALUES (6017, 'Majadito de Pato', 'Plato cruceño tradicional con carne de pato desmechada, huevo y plátano', 45.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6018, 'Pique Macho Tradicional', 'Lomito, salchicha, papas fritas, huevo, cebolla, tomate y locoto', 65.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6019, 'Sopa de Maní', 'Deliciosa sopa tradicional con fideo macarrón y papas fritas encima', 25.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6020, 'Silpancho Cochabambino', 'Carne apanada gigante, arroz, papas doradas, huevo y ensalada', 35.00, 'Activo');
  
  -- Pizzerías
  INSERT INTO PRODUCTO VALUES (6021, 'Pizza Pepperoni Familiar', 'Masa tradicional, salsa de tomate, mozzarella y pepperoni', 75.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6022, 'Pizza Margarita Mediana', 'Masa artesanal, salsa pomodoro, mozzarella fresca y albahaca', 55.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6023, 'Pizza Hawaiana Familiar', 'Mozzarella, jamón y piña fresca en trozos', 70.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6024, 'Pizza Carnívora Familiar', 'Pepperoni, jamón, salchicha italiana y tocino', 85.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6025, 'Pizza 4 Quesos Grande', 'Mezcla de queso mozzarella, parmesano, gorgonzola y provolone', 80.00, 'Agotado');
  INSERT INTO PRODUCTO VALUES (6026, 'Pizza Vegetariana Mediana', 'Champiñones, pimientos, cebolla, aceitunas y tomate', 60.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6027, 'Calzone de Carne', 'Masa de pizza rellena de carne picada, queso y salsa', 45.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6028, 'Palitroques de Queso', 'Pan de ajo con extra queso y salsa para mojar', 25.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6029, 'Lasaña a la Boloñesa', 'Capas de pasta con salsa boloñesa, bechamel y queso parmesano', 40.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6030, 'Espagueti Carbonara', 'Pasta tradicional con salsa de huevo, queso, panceta y pimienta', 38.00, 'Inactivo');

  -- Chifas y Comida Asiática
  INSERT INTO PRODUCTO VALUES (6031, 'Arroz Frito Chaufa', 'Arroz saltado con pollo, huevo, cebollín y salsa de soya', 35.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6032, 'Sopa Wantán', 'Caldo claro con empanaditas de cerdo y pollo, cebollín', 28.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6033, 'Tallarín Saltado de Carne', 'Fideos chinos salteados al wok con verduras y lomo de res', 42.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6034, 'Cerdo Agridulce', 'Trozos de cerdo empanizado con salsa agridulce, piña y pimientos', 45.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6035, 'Pollo Chi Jau Kay', 'Trozos de pollo crocante bañados en salsa de ajo y ostión', 48.00, 'Agotado');
  INSERT INTO PRODUCTO VALUES (6036, 'Rollo de Primavera x4', 'Rollitos crujientes rellenos de verduras frescas', 15.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6037, 'California Roll', 'Maki sushi con kanikama, palta, pepino y sésamo (8 cortes)', 35.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6038, 'Salmon Spicy Roll', 'Maki de salmón fresco, palta y salsa picante (8 cortes)', 45.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6039, 'Acevichado Roll', 'Roll relleno de langostino empanizado, cubierto con atún y salsa acevichada', 55.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6040, 'Nigiri de Salmón x2', 'Bocados tradicionales de arroz cubiertos con lámina de salmón', 25.00, 'Activo');

  -- Panaderías y Cafeterías
  INSERT INTO PRODUCTO VALUES (6041, 'Café Americano', 'Espresso diluido en agua caliente', 15.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6042, 'Cappuccino Clásico', 'Espresso con leche vaporizada y espuma de leche', 20.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6043, 'Café Latte', 'Espresso con abundante leche vaporizada', 18.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6044, 'Moccachino', 'Latte con jarabe de chocolate', 22.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6045, 'Frappé de Caramelo', 'Bebida fría batida con hielo, café y salsa de caramelo', 28.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6046, 'Té Chai Latte', 'Infusión de té negro con especias y leche vaporizada', 20.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6047, 'Porción de Torta de Chocolate', 'Bizcocho húmedo de chocolate con fudge', 25.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6048, 'Porción de Torta Tres Leches', 'Bizcocho bañado en tres tipos de leche', 22.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6049, 'Cheesecake de Frutos Rojos', 'Tarta de queso con jalea casera de frutos rojos', 28.00, 'Agotado');
  INSERT INTO PRODUCTO VALUES (6050, 'Pan Marraqueta x10', 'Paquete de 10 panes marraqueta tradicionales', 10.00, 'Activo');

  -- Heladerías y Postres
  INSERT INTO PRODUCTO VALUES (6051, 'Helado 2 Sabores', 'Copa de helado artesanal con dos porciones a elección', 18.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6052, 'Banana Split', 'Helado de tres sabores, plátano fresco, crema chantilly y cereza', 35.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6053, 'Copa Sundae', 'Helado clásico con sirope de chocolate y nueces', 25.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6054, 'Churros Rellenos de Dulce de Leche x4', 'Cuatro churros crujientes rellenos', 20.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6055, 'Churros Simples x6', 'Seis churros con azúcar y canela', 15.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6056, 'Milkshake de Fresa', 'Batido espeso de helado de fresa y leche', 22.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6057, 'Milkshake de Oreo', 'Batido de helado de vainilla con galletas Oreo trituradas', 25.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6058, 'Rollo de Canela', 'Clásico rollo de canela glaseado', 18.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6059, 'Helado de Yogurt Frutos del Bosque', 'Yogurt helado con topping de frutas naturales', 28.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6060, 'Paleta de Helado Frutilla', 'Paleta clásica de agua sabor frutilla', 5.00, 'Activo');

  -- Bebidas Básicas (Para todos los restaurantes)
  INSERT INTO PRODUCTO VALUES (6061, 'Coca Cola 2 Litros', 'Gaseosa Coca Cola envase PET', 15.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6062, 'Coca Cola 500ml', 'Gaseosa Coca Cola personal', 6.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6063, 'Sprite 2 Litros', 'Gaseosa Sprite envase PET', 14.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6064, 'Fanta Naranja 500ml', 'Gaseosa Fanta personal', 6.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6065, 'Agua Vital Sin Gas 600ml', 'Agua purificada embotellada sin gas', 5.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6066, 'Agua Vital Con Gas 600ml', 'Agua purificada embotellada con gas', 5.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6067, 'Jugo del Valle Durazno 1L', 'Jugo envasado sabor durazno', 12.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6068, 'Jugo Pil Naranja 1L', 'Jugo envasado sabor naranja', 11.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6069, 'Limonada Frozen', 'Bebida granizada de limón natural', 15.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6070, 'Té Helado de Durazno', 'Infusión fría de té con sabor a durazno', 12.00, 'Activo');

  -- Extra Variados Comida (Completando el bloque 1)
  INSERT INTO PRODUCTO VALUES (6071, 'Alitas Picantes x6', 'Alitas de pollo bañadas en salsa buffalo picante', 35.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6072, 'Alitas BBQ x6', 'Alitas de pollo bañadas en salsa barbacoa dulce', 35.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6073, 'Sándwich de Chola', 'Sándwich de cerdo tradicional paceño con escabeche y llajua', 18.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6074, 'Cuñapé Tradicional x5', 'Masa de queso y almidón de yuca horneada', 15.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6075, 'Sonso al Horno', 'Puré de yuca con queso horneado en palo', 12.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6076, 'Huminta al Horno', 'Masa dulce de maíz horneada en su chala', 8.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6077, 'Pizza Prosciutto Mediana', 'Pizza con jamón crudo italiano y rúcula fresca', 65.00, 'Inactivo');
  INSERT INTO PRODUCTO VALUES (6078, 'Ceviche Mixto', 'Pescado y mariscos marinados en jugo de limón', 55.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6079, 'Jalea Mixta', 'Mariscos y trozos de pescado fritos con yuca', 60.00, 'Agotado');
  INSERT INTO PRODUCTO VALUES (6080, 'Churrasco Simple', 'Corte de carne a la parrilla con arroz con queso y yuca', 65.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6081, 'Bife Chorizo', 'Corte de carne gruesa a la parrilla con guarniciones', 90.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6082, 'Tira de Asado', 'Costillar de res cortado transversalmente a la parrilla', 85.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6083, 'Mocochinchi 1L', 'Bebida tradicional hervida de durazno deshidratado', 10.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6084, 'Somó', 'Bebida fría a base de maíz frangollo', 8.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6085, 'Chicha Morada 1L', 'Bebida tradicional a base de maíz morado', 12.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6086, 'Lomito a la Plancha', 'Sándwich de lomo de res con tomate, lechuga y huevo', 22.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6087, 'Sopa de Pollo', 'Caldo de pollo casero con verduras y fideo', 20.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6088, 'Ensalada César', 'Lechuga romana, crutones, queso parmesano y pollo a la plancha', 35.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6089, 'Ensalada Rusa', 'Papas, zanahoria, arvejas y pollo con mayonesa', 25.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6090, 'Milanesa de Pollo', 'Filete de pollo empanizado con papas y arroz', 30.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6091, 'Falso Conejo', 'Carne de res apanada en salsa de ají con fideo, chuño y papa', 30.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6092, 'Sajta de Pollo', 'Pollo en salsa de ají amarillo con chuño, papa y sarsa', 35.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6093, 'Charquekan', 'Carne deshidratada de llama frita con mote, huevo, queso y papa', 45.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6094, 'Choripán', 'Chorizo a la parrilla servido en pan francés con chimichurri', 15.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6095, 'Anticucho', 'Brocheta de corazón de res marinada a la parrilla con papa', 12.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6096, 'Ravioles de Queso', 'Pasta rellena de ricota y espinaca con salsa pomodoro', 42.00, 'Inactivo');
  INSERT INTO PRODUCTO VALUES (6097, 'Fettuccine Alfredo', 'Pasta larga con crema, queso parmesano y mantequilla', 38.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6098, 'Costillas BBQ', 'Medio costillar de cerdo horneado a baja temperatura con salsa barbacoa', 85.00, 'Agotado');
  INSERT INTO PRODUCTO VALUES (6099, 'Punta de S. a la Parrilla', 'Corte jugoso de carne con ensalada mixta y yuca frita', 110.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6100, 'Keperi al Horno', 'Corte de carne cocido a fuego lento, muy suave, con arroz', 55.00, 'Activo');

  COMMIT;
END;
 

BEGIN
  -- Churrasquerías y Grill (Continuación)
  INSERT INTO PRODUCTO VALUES (6101, 'Pacumutu Mixto', 'Brocheta gigante de carne de res, pollo, chorizo y vegetales', 55.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6102, 'Matambre a la Pizza', 'Corte de res tierno cubierto con salsa de tomate y queso fundido', 75.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6103, 'Pollo a la Leña Fino', 'Medio pollo cocido a la leña con papas rústicas', 40.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6104, 'Salchicha Parrillera x2', 'Dos unidades de salchicha de cerdo asadas', 18.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6105, 'Provoleta a la Parrilla', 'Queso provolone fundido al carbón con orégano', 30.00, 'Activo');

  -- Farmacias (Medicamentos OTC y Cuidado Personal)
  INSERT INTO PRODUCTO VALUES (6106, 'Paracetamol 500mg x10', 'Blister de paracetamol para alivio del dolor y fiebre', 5.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6107, 'Ibuprofeno 400mg x10', 'Blister de antiinflamatorio', 8.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6108, 'Jarabe para la Tos Infantil', 'Jarabe expectorante sabor frutilla 120ml', 35.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6109, 'Vitamina C 1000mg Tubo', 'Comprimidos efervescentes sabor naranja x10', 25.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6110, 'Alcohol en Gel 500ml', 'Desinfectante de manos al 70%', 15.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6111, 'Barbijo Quirúrgico Caja x50', 'Mascarillas desechables tricapa azules', 20.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6112, 'Protector Solar SPF 50', 'Crema facial y corporal resistente al agua 150ml', 85.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6113, 'Pañales Huggies Etapa 3', 'Paquete de 30 unidades para bebés', 65.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6114, 'Toallitas Húmedas Bebé', 'Paquete de 100 unidades con aloe vera', 22.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6115, 'Termómetro Digital', 'Termómetro de medición rápida con alarma', 45.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6116, 'Shampoo Anticaspa 400ml', 'Shampoo cuidado diario para cuero cabelludo', 35.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6117, 'Pasta Dental 150g', 'Crema dental con flúor triple acción', 14.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6118, 'Desodorante Aerosol 150ml', 'Antitranspirante protección 48h', 25.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6119, 'Algodón Hidrófilo 100g', 'Paquete de algodón puro uso médico', 10.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6120, 'Antigripal en Sobres x5', 'Infusión caliente para síntomas del resfrío', 15.00, 'Agotado');
  INSERT INTO PRODUCTO VALUES (6121, 'Sales de Rehidratación Oral', 'Sobre de suero sabor naranja', 8.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6122, 'Aspirina Fuerte x10', 'Ácido acetilsalicílico para dolores intensos', 12.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6123, 'Crema Cicatrizante', 'Pomada para heridas leves y quemaduras menores 30g', 45.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6124, 'Pastillas para Garganta x12', 'Caramelos anestésicos sabor menta', 20.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6125, 'Gotas para Irritación Ocular', 'Colirio lubricante 15ml', 38.00, 'Inactivo');

  -- Supermercados (Abarrotes, Snacks, Limpieza)
  INSERT INTO PRODUCTO VALUES (6126, 'Aceite de Girasol Fino 1L', 'Aceite comestible puro de girasol', 18.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6127, 'Arroz Grano Largo 1Kg', 'Bolsa de arroz blanco seleccionado de primera', 9.50, 'Activo');
  INSERT INTO PRODUCTO VALUES (6128, 'Azúcar Blanca 1Kg', 'Azúcar granulada refinada', 6.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6129, 'Fideo Macarrón 400g', 'Pasta de trigo duro ideal para sopas', 5.50, 'Activo');
  INSERT INTO PRODUCTO VALUES (6130, 'Sal Yodada 1Kg', 'Sal fina enriquecida con yodo', 3.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6131, 'Leche Pil Entera 1L', 'Leche UHT en sachet', 7.50, 'Activo');
  INSERT INTO PRODUCTO VALUES (6132, 'Leche Pil Deslactosada 1L', 'Leche UHT de fácil digestión', 8.50, 'Activo');
  INSERT INTO PRODUCTO VALUES (6133, 'Queso San Javier 500g', 'Queso fresco paceño ideal para sándwich', 28.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6134, 'Mantequilla Pil 200g', 'Mantequilla con sal en barra', 14.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6135, 'Huevo de Granja Maple x30', 'Cartón de 30 huevos tamaño grande', 25.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6136, 'Pan Tajado Blanco', 'Bolsa de pan de molde tajado grande', 15.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6137, 'Galletas Mabel''s Salvado', 'Galletas dulces de salvado de trigo', 6.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6138, 'Galletas Cremositas Chocolate', 'Paquete de galletas rellenas', 5.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6139, 'Papas Fritas Lays 100g', 'Snack de papas sabor original', 14.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6140, 'Doritos Queso 100g', 'Snack de tortillas de maíz sabor queso', 14.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6141, 'Chocolates Sublime x3', 'Tableta de chocolate con maní', 9.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6142, 'Detergente Líquido Omo 1L', 'Detergente para lavar ropa', 20.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6143, 'Lavavajillas Ola 500g', 'Pasta lavavajillas aroma limón', 12.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6144, 'Papel Higiénico Scott x4', 'Paquete de 4 rollos doble hoja', 18.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6145, 'Limpiador de Pisos Poett 1L', 'Líquido desinfectante aroma lavanda', 15.00, 'Activo');

  -- Licorerías y Tiendas de conveniencia (Bebidas alcohólicas y extras)
  INSERT INTO PRODUCTO VALUES (6146, 'Cerveza Paceña Lata 354ml', 'Cerveza rubia tradicional en lata', 8.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6147, 'Cerveza Huari Botella 620ml', 'Cerveza premium botella de vidrio retornable', 15.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6148, 'Cerveza Corona Six Pack', 'Pack de 6 botellas pequeñas de 330ml', 55.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6149, 'Singani Casa Real Etiqueta Negra', 'Destilado de uva moscatel botella 750ml', 85.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6150, 'Singani Los Parrales', 'Singani tradicional botella 750ml', 70.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6151, 'Ron Flor de Caña 750ml', 'Ron añejo reserva botella de vidrio', 95.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6152, 'Vodka Smirnoff 750ml', 'Vodka clásico botella 750ml', 80.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6153, 'Whisky Absolut 750ml', 'Whisky importado botella de vidrio', 110.00, 'Agotado');
  INSERT INTO PRODUCTO VALUES (6154, 'Fernet Branca 750ml', 'Licor de hierbas italiano', 120.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6155, 'Vino Aranjuez Cabernet', 'Vino tinto boliviano botella 750ml', 65.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6156, 'Vino Kohlberg Syrah', 'Vino tinto tarijeño botella 750ml', 55.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6157, 'Combo Fernet + Coca Cola', 'Botella de Fernet 750ml + Coca Cola 2L', 130.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6158, 'Combo Singani + Sprite', 'Botella Singani Casa Real + Sprite 2L + Limón', 105.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6159, 'Bebida Energizante Red Bull', 'Lata de bebida energizante 250ml', 15.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6160, 'Bebida Energizante Monster', 'Lata de bebida energizante 473ml', 18.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6161, 'Hielo en Cubos Bolsa 2Kg', 'Bolsa de hielo purificado', 12.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6162, 'Agua Tónica 2L', 'Bebida gasificada ideal para tragos', 15.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6163, 'Snack Maní Salado 200g', 'Bolsa de maní tostado y salado', 10.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6164, 'Pistachos Tostados 150g', 'Pistachos importados en bolsa', 35.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6165, 'Cigarrillos Marlboro Rojo', 'Cajetilla de 20 cigarrillos', 20.00, 'Activo');

  -- Mix General para Farmacias   Tiendas   Supermercados
  INSERT INTO PRODUCTO VALUES (6166, 'Jaboncillo Protex', 'Jabón en barra para lavar ropa 200g', 6.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6167, 'Jabón de Tocador Rexona', 'Jabón antibacterial en barra', 7.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6168, 'Esponja Scotch Brite', 'Esponja doble uso para cocina', 5.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6169, 'Detergente en Polvo Bolívar 1Kg', 'Detergente en polvo multiuso', 16.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6170, 'Shampoo Sedal 350ml', 'Shampoo restauración diaria', 22.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6171, 'Acondicionador Sedal 350ml', 'Crema de enjuague para el cabello', 22.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6172, 'Crema Corporal Nivea 200ml', 'Crema humectante para piel seca', 28.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6173, 'Enjuague Bucal Listerine 250ml', 'Antiséptico bucal mentolado', 20.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6174, 'Máquina de Afeitar Gillette x2', 'Paquete de 2 rasuradoras desechables', 14.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6175, 'Preservativos Prime x3', 'Caja de 3 unidades textura fina', 15.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6176, 'Toallas Femeninas Nosotras', 'Paquete de 10 toallas con alas', 12.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6177, 'Desodorante Roll-On Dove', 'Antitranspirante roll-on 50ml', 18.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6178, 'Cereal Zucaritas 500g', 'Caja de hojuelas de maíz azucaradas', 30.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6179, 'Avena Kris 500g', 'Bolsa de hojuelas de avena tradicional', 12.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6180, 'Sardina en Lata', 'Sardina en salsa de tomate 150g', 8.00, 'Agotado');
  INSERT INTO PRODUCTO VALUES (6181, 'Atún en Aceite', 'Lata de atún en lomos 170g', 15.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6182, 'Mayonesa Kris 200g', 'Sachet de mayonesa tradicional', 8.50, 'Activo');
  INSERT INTO PRODUCTO VALUES (6183, 'Kétchup Kris 200g', 'Sachet de salsa de tomate', 7.50, 'Activo');
  INSERT INTO PRODUCTO VALUES (6184, 'Mostaza Kris 200g', 'Sachet de salsa de mostaza', 7.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6185, 'Salsa Soya Kikko 250ml', 'Botella de salsa de soya oscura', 12.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6186, 'Vinagre Blanco 500ml', 'Botella de vinagre de alcohol', 6.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6187, 'Aceitunas Verdes 200g', 'Frasco de aceitunas descarozadas', 18.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6188, 'Palmitos en Conserva', 'Frasco de palmitos enteros 400g', 25.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6189, 'Champiñones en Lata', 'Lata de champiñones laminados', 20.00, 'Inactivo');
  INSERT INTO PRODUCTO VALUES (6190, 'Puré de Tomate 520g', 'Caja de salsa de tomate lista', 10.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6191, 'Levadura en Polvo x3', 'Sobres de levadura para hornear', 5.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6192, 'Esencia de Vainilla 100ml', 'Botella pequeña de vainilla', 8.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6193, 'Harina de Trigo Famosa 1Kg', 'Bolsa de harina refinada 000', 8.50, 'Activo');
  INSERT INTO PRODUCTO VALUES (6194, 'Miel de Abeja 250g', 'Frasco de miel pura de abeja', 25.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6195, 'Mermelada de Frutilla 500g', 'Frasco de mermelada tradicional', 18.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6196, 'Dulce de Leche Pil 400g', 'Pote de dulce de leche cremoso', 20.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6197, 'Gelatina de Limón', 'Sobre para preparar gelatina 1L', 5.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6198, 'Flan de Vainilla', 'Sobre para preparar flan con caramelo', 6.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6199, 'Pudin de Chocolate', 'Postre lácteo listo para servir', 8.00, 'Activo');
  INSERT INTO PRODUCTO VALUES (6200, 'Galletas de Agua', 'Paquete de galletas saladas clásicas', 5.50, 'Activo');

  COMMIT;
END;
 


--OFRECE
BEGIN
  INSERT INTO OFRECE VALUES (4001, 6006);
  INSERT INTO OFRECE VALUES (4001, 6009);
  INSERT INTO OFRECE VALUES (4001, 6061);
  INSERT INTO OFRECE VALUES (4001, 6062);
  INSERT INTO OFRECE VALUES (4001, 6064);
  INSERT INTO OFRECE VALUES (4001, 6103);
  INSERT INTO OFRECE VALUES (4002, 6001);
  INSERT INTO OFRECE VALUES (4002, 6004);
  INSERT INTO OFRECE VALUES (4002, 6008);
  INSERT INTO OFRECE VALUES (4002, 6009);
  INSERT INTO OFRECE VALUES (4002, 6061);
  INSERT INTO OFRECE VALUES (4003, 6002);
  INSERT INTO OFRECE VALUES (4003, 6005);
  INSERT INTO OFRECE VALUES (4003, 6006);
  INSERT INTO OFRECE VALUES (4003, 6063);
  INSERT INTO OFRECE VALUES (4004, 6004);
  INSERT INTO OFRECE VALUES (4004, 6006);
  INSERT INTO OFRECE VALUES (4004, 6007);
  INSERT INTO OFRECE VALUES (4004, 6062);
  INSERT INTO OFRECE VALUES (4004, 6066);
  INSERT INTO OFRECE VALUES (4005, 6002);
  INSERT INTO OFRECE VALUES (4005, 6004);
  INSERT INTO OFRECE VALUES (4005, 6006);
  INSERT INTO OFRECE VALUES (4005, 6068);
  INSERT INTO OFRECE VALUES (4005, 6084);
  INSERT INTO OFRECE VALUES (4005, 6103);
  INSERT INTO OFRECE VALUES (4006, 6002);
  INSERT INTO OFRECE VALUES (4006, 6004);
  INSERT INTO OFRECE VALUES (4006, 6009);
  INSERT INTO OFRECE VALUES (4006, 6066);
  INSERT INTO OFRECE VALUES (4006, 6067);
  INSERT INTO OFRECE VALUES (4006, 6083);
  INSERT INTO OFRECE VALUES (4007, 6004);
  INSERT INTO OFRECE VALUES (4007, 6005);
  INSERT INTO OFRECE VALUES (4007, 6007);
  INSERT INTO OFRECE VALUES (4007, 6010);
  INSERT INTO OFRECE VALUES (4007, 6062);
  INSERT INTO OFRECE VALUES (4007, 6064);
  INSERT INTO OFRECE VALUES (4008, 6005);
  INSERT INTO OFRECE VALUES (4008, 6009);
  INSERT INTO OFRECE VALUES (4008, 6010);
  INSERT INTO OFRECE VALUES (4008, 6068);
  INSERT INTO OFRECE VALUES (4009, 6001);
  INSERT INTO OFRECE VALUES (4009, 6005);
  INSERT INTO OFRECE VALUES (4009, 6007);
  INSERT INTO OFRECE VALUES (4009, 6009);
  INSERT INTO OFRECE VALUES (4009, 6066);
  INSERT INTO OFRECE VALUES (4009, 6068);
  INSERT INTO OFRECE VALUES (4010, 6003);
  INSERT INTO OFRECE VALUES (4010, 6008);
  INSERT INTO OFRECE VALUES (4010, 6010);
  INSERT INTO OFRECE VALUES (4010, 6062);
  INSERT INTO OFRECE VALUES (4010, 6066);
  INSERT INTO OFRECE VALUES (4011, 6004);
  INSERT INTO OFRECE VALUES (4011, 6006);
  INSERT INTO OFRECE VALUES (4011, 6007);
  INSERT INTO OFRECE VALUES (4011, 6008);
  INSERT INTO OFRECE VALUES (4011, 6068);
  INSERT INTO OFRECE VALUES (4011, 6084);
  INSERT INTO OFRECE VALUES (4012, 6001);
  INSERT INTO OFRECE VALUES (4012, 6003);
  INSERT INTO OFRECE VALUES (4012, 6006);
  INSERT INTO OFRECE VALUES (4012, 6010);
  INSERT INTO OFRECE VALUES (4012, 6061);
  INSERT INTO OFRECE VALUES (4012, 6070);
  INSERT INTO OFRECE VALUES (4013, 6004);
  INSERT INTO OFRECE VALUES (4013, 6006);
  INSERT INTO OFRECE VALUES (4013, 6010);
  INSERT INTO OFRECE VALUES (4013, 6062);
  INSERT INTO OFRECE VALUES (4013, 6069);
  INSERT INTO OFRECE VALUES (4014, 6001);
  INSERT INTO OFRECE VALUES (4014, 6008);
  INSERT INTO OFRECE VALUES (4014, 6009);
  INSERT INTO OFRECE VALUES (4014, 6063);
  INSERT INTO OFRECE VALUES (4014, 6066);
  INSERT INTO OFRECE VALUES (4014, 6072);
  INSERT INTO OFRECE VALUES (4015, 6005);
  INSERT INTO OFRECE VALUES (4015, 6008);
  INSERT INTO OFRECE VALUES (4015, 6010);
  INSERT INTO OFRECE VALUES (4015, 6063);
  INSERT INTO OFRECE VALUES (4015, 6066);
  INSERT INTO OFRECE VALUES (4016, 6005);
  INSERT INTO OFRECE VALUES (4016, 6006);
  INSERT INTO OFRECE VALUES (4016, 6010);
  INSERT INTO OFRECE VALUES (4016, 6063);
  INSERT INTO OFRECE VALUES (4016, 6065);
  INSERT INTO OFRECE VALUES (4017, 6001);
  INSERT INTO OFRECE VALUES (4017, 6006);
  INSERT INTO OFRECE VALUES (4017, 6007);
  INSERT INTO OFRECE VALUES (4017, 6064);
  INSERT INTO OFRECE VALUES (4017, 6071);
  INSERT INTO OFRECE VALUES (4018, 6002);
  INSERT INTO OFRECE VALUES (4018, 6005);
  INSERT INTO OFRECE VALUES (4018, 6007);
  INSERT INTO OFRECE VALUES (4018, 6008);
  INSERT INTO OFRECE VALUES (4018, 6067);
  INSERT INTO OFRECE VALUES (4018, 6083);
  INSERT INTO OFRECE VALUES (4019, 6004);
  INSERT INTO OFRECE VALUES (4019, 6007);
  INSERT INTO OFRECE VALUES (4019, 6009);
  INSERT INTO OFRECE VALUES (4019, 6010);
  INSERT INTO OFRECE VALUES (4019, 6065);
  INSERT INTO OFRECE VALUES (4019, 6069);
  INSERT INTO OFRECE VALUES (4020, 6001);
  INSERT INTO OFRECE VALUES (4020, 6008);
  INSERT INTO OFRECE VALUES (4020, 6009);
  INSERT INTO OFRECE VALUES (4020, 6063);
  INSERT INTO OFRECE VALUES (4020, 6068);
  INSERT INTO OFRECE VALUES (4021, 6001);
  INSERT INTO OFRECE VALUES (4021, 6005);
  INSERT INTO OFRECE VALUES (4021, 6009);
  INSERT INTO OFRECE VALUES (4021, 6061);
  INSERT INTO OFRECE VALUES (4022, 6005);
  INSERT INTO OFRECE VALUES (4022, 6007);
  INSERT INTO OFRECE VALUES (4022, 6008);
  INSERT INTO OFRECE VALUES (4022, 6062);
  INSERT INTO OFRECE VALUES (4022, 6067);
  INSERT INTO OFRECE VALUES (4023, 6001);
  INSERT INTO OFRECE VALUES (4023, 6002);
  INSERT INTO OFRECE VALUES (4023, 6006);
  INSERT INTO OFRECE VALUES (4023, 6010);
  INSERT INTO OFRECE VALUES (4023, 6065);
  INSERT INTO OFRECE VALUES (4023, 6069);
  INSERT INTO OFRECE VALUES (4024, 6003);
  INSERT INTO OFRECE VALUES (4024, 6006);
  INSERT INTO OFRECE VALUES (4024, 6008);
  INSERT INTO OFRECE VALUES (4024, 6009);
  INSERT INTO OFRECE VALUES (4024, 6061);
  INSERT INTO OFRECE VALUES (4024, 6069);
  INSERT INTO OFRECE VALUES (4025, 6004);
  INSERT INTO OFRECE VALUES (4025, 6009);
  INSERT INTO OFRECE VALUES (4025, 6010);
  INSERT INTO OFRECE VALUES (4025, 6064);
  INSERT INTO OFRECE VALUES (4025, 6067);
  INSERT INTO OFRECE VALUES (4025, 6103);
  INSERT INTO OFRECE VALUES (4026, 6003);
  INSERT INTO OFRECE VALUES (4026, 6005);
  INSERT INTO OFRECE VALUES (4026, 6008);
  INSERT INTO OFRECE VALUES (4026, 6009);
  INSERT INTO OFRECE VALUES (4026, 6061);
  INSERT INTO OFRECE VALUES (4027, 6001);
  INSERT INTO OFRECE VALUES (4027, 6007);
  INSERT INTO OFRECE VALUES (4027, 6008);
  INSERT INTO OFRECE VALUES (4027, 6062);
  INSERT INTO OFRECE VALUES (4027, 6070);
  INSERT INTO OFRECE VALUES (4028, 6001);
  INSERT INTO OFRECE VALUES (4028, 6002);
  INSERT INTO OFRECE VALUES (4028, 6006);
  INSERT INTO OFRECE VALUES (4028, 6068);
  INSERT INTO OFRECE VALUES (4028, 6069);
  INSERT INTO OFRECE VALUES (4029, 6018);
  INSERT INTO OFRECE VALUES (4029, 6020);
  INSERT INTO OFRECE VALUES (4029, 6064);
  INSERT INTO OFRECE VALUES (4029, 6067);
  INSERT INTO OFRECE VALUES (4029, 6081);
  INSERT INTO OFRECE VALUES (4029, 6082);
  INSERT INTO OFRECE VALUES (4029, 6088);
  INSERT INTO OFRECE VALUES (4029, 6090);
  INSERT INTO OFRECE VALUES (4029, 6092);
  INSERT INTO OFRECE VALUES (4030, 6018);
  INSERT INTO OFRECE VALUES (4030, 6019);
  INSERT INTO OFRECE VALUES (4030, 6067);
  INSERT INTO OFRECE VALUES (4030, 6070);
  INSERT INTO OFRECE VALUES (4030, 6083);
  INSERT INTO OFRECE VALUES (4030, 6092);
  INSERT INTO OFRECE VALUES (4030, 6100);
  INSERT INTO OFRECE VALUES (4031, 6019);
  INSERT INTO OFRECE VALUES (4031, 6020);
  INSERT INTO OFRECE VALUES (4031, 6065);
  INSERT INTO OFRECE VALUES (4031, 6066);
  INSERT INTO OFRECE VALUES (4031, 6081);
  INSERT INTO OFRECE VALUES (4031, 6091);
  INSERT INTO OFRECE VALUES (4032, 6018);
  INSERT INTO OFRECE VALUES (4032, 6020);
  INSERT INTO OFRECE VALUES (4032, 6061);
  INSERT INTO OFRECE VALUES (4032, 6081);
  INSERT INTO OFRECE VALUES (4032, 6082);
  INSERT INTO OFRECE VALUES (4032, 6085);
  INSERT INTO OFRECE VALUES (4032, 6090);
  COMMIT;
END;

BEGIN
  INSERT INTO OFRECE VALUES (4033, 6020);
  INSERT INTO OFRECE VALUES (4033, 6063);
  INSERT INTO OFRECE VALUES (4033, 6081);
  INSERT INTO OFRECE VALUES (4033, 6090);
  INSERT INTO OFRECE VALUES (4033, 6091);
  INSERT INTO OFRECE VALUES (4034, 6017);
  INSERT INTO OFRECE VALUES (4034, 6018);
  INSERT INTO OFRECE VALUES (4034, 6065);
  INSERT INTO OFRECE VALUES (4034, 6080);
  INSERT INTO OFRECE VALUES (4034, 6082);
  INSERT INTO OFRECE VALUES (4034, 6090);
  INSERT INTO OFRECE VALUES (4034, 6096);
  INSERT INTO OFRECE VALUES (4035, 6018);
  INSERT INTO OFRECE VALUES (4035, 6020);
  INSERT INTO OFRECE VALUES (4035, 6063);
  INSERT INTO OFRECE VALUES (4035, 6066);
  INSERT INTO OFRECE VALUES (4035, 6082);
  INSERT INTO OFRECE VALUES (4035, 6092);
  INSERT INTO OFRECE VALUES (4036, 6018);
  INSERT INTO OFRECE VALUES (4036, 6019);
  INSERT INTO OFRECE VALUES (4036, 6020);
  INSERT INTO OFRECE VALUES (4036, 6061);
  INSERT INTO OFRECE VALUES (4036, 6081);
  INSERT INTO OFRECE VALUES (4036, 6083);
  INSERT INTO OFRECE VALUES (4036, 6093);
  INSERT INTO OFRECE VALUES (4036, 6096);
  INSERT INTO OFRECE VALUES (4036, 6100);
  INSERT INTO OFRECE VALUES (4037, 6017);
  INSERT INTO OFRECE VALUES (4037, 6062);
  INSERT INTO OFRECE VALUES (4037, 6082);
  INSERT INTO OFRECE VALUES (4037, 6088);
  INSERT INTO OFRECE VALUES (4037, 6094);
  INSERT INTO OFRECE VALUES (4037, 6098);
  INSERT INTO OFRECE VALUES (4038, 6017);
  INSERT INTO OFRECE VALUES (4038, 6020);
  INSERT INTO OFRECE VALUES (4038, 6063);
  INSERT INTO OFRECE VALUES (4038, 6064);
  INSERT INTO OFRECE VALUES (4038, 6081);
  INSERT INTO OFRECE VALUES (4038, 6082);
  INSERT INTO OFRECE VALUES (4038, 6088);
  INSERT INTO OFRECE VALUES (4038, 6098);
  INSERT INTO OFRECE VALUES (4039, 6044);
  INSERT INTO OFRECE VALUES (4039, 6046);
  INSERT INTO OFRECE VALUES (4039, 6047);
  INSERT INTO OFRECE VALUES (4039, 6059);
  INSERT INTO OFRECE VALUES (4039, 6075);
  INSERT INTO OFRECE VALUES (4040, 6042);
  INSERT INTO OFRECE VALUES (4040, 6047);
  INSERT INTO OFRECE VALUES (4040, 6050);
  INSERT INTO OFRECE VALUES (4040, 6058);
  INSERT INTO OFRECE VALUES (4040, 6066);
  INSERT INTO OFRECE VALUES (4041, 6045);
  INSERT INTO OFRECE VALUES (4041, 6046);
  INSERT INTO OFRECE VALUES (4041, 6048);
  INSERT INTO OFRECE VALUES (4041, 6050);
  INSERT INTO OFRECE VALUES (4041, 6076);
  INSERT INTO OFRECE VALUES (4042, 6041);
  INSERT INTO OFRECE VALUES (4042, 6042);
  INSERT INTO OFRECE VALUES (4042, 6043);
  INSERT INTO OFRECE VALUES (4042, 6058);
  INSERT INTO OFRECE VALUES (4042, 6075);
  INSERT INTO OFRECE VALUES (4043, 6045);
  INSERT INTO OFRECE VALUES (4043, 6049);
  INSERT INTO OFRECE VALUES (4043, 6059);
  INSERT INTO OFRECE VALUES (4043, 6065);
  INSERT INTO OFRECE VALUES (4044, 6045);
  INSERT INTO OFRECE VALUES (4044, 6046);
  INSERT INTO OFRECE VALUES (4044, 6047);
  INSERT INTO OFRECE VALUES (4044, 6048);
  INSERT INTO OFRECE VALUES (4044, 6070);
  INSERT INTO OFRECE VALUES (4045, 6041);
  INSERT INTO OFRECE VALUES (4045, 6042);
  INSERT INTO OFRECE VALUES (4045, 6058);
  INSERT INTO OFRECE VALUES (4045, 6059);
  INSERT INTO OFRECE VALUES (4045, 6076);
  INSERT INTO OFRECE VALUES (4046, 6042);
  INSERT INTO OFRECE VALUES (4046, 6043);
  INSERT INTO OFRECE VALUES (4046, 6046);
  INSERT INTO OFRECE VALUES (4046, 6076);
  INSERT INTO OFRECE VALUES (4047, 6041);
  INSERT INTO OFRECE VALUES (4047, 6045);
  INSERT INTO OFRECE VALUES (4047, 6048);
  INSERT INTO OFRECE VALUES (4047, 6065);
  INSERT INTO OFRECE VALUES (4047, 6074);
  INSERT INTO OFRECE VALUES (4048, 6041);
  INSERT INTO OFRECE VALUES (4048, 6043);
  INSERT INTO OFRECE VALUES (4048, 6049);
  INSERT INTO OFRECE VALUES (4048, 6058);
  INSERT INTO OFRECE VALUES (4048, 6074);
  INSERT INTO OFRECE VALUES (4049, 6046);
  INSERT INTO OFRECE VALUES (4049, 6049);
  INSERT INTO OFRECE VALUES (4049, 6050);
  INSERT INTO OFRECE VALUES (4049, 6070);
  INSERT INTO OFRECE VALUES (4049, 6076);
  INSERT INTO OFRECE VALUES (4050, 6041);
  INSERT INTO OFRECE VALUES (4050, 6047);
  INSERT INTO OFRECE VALUES (4050, 6048);
  INSERT INTO OFRECE VALUES (4050, 6058);
  INSERT INTO OFRECE VALUES (4050, 6074);
  INSERT INTO OFRECE VALUES (4051, 6013);
  INSERT INTO OFRECE VALUES (4051, 6016);
  INSERT INTO OFRECE VALUES (4051, 6065);
  INSERT INTO OFRECE VALUES (4051, 6075);
  INSERT INTO OFRECE VALUES (4052, 6011);
  INSERT INTO OFRECE VALUES (4052, 6013);
  INSERT INTO OFRECE VALUES (4052, 6050);
  INSERT INTO OFRECE VALUES (4052, 6065);
  INSERT INTO OFRECE VALUES (4052, 6069);
  INSERT INTO OFRECE VALUES (4053, 6013);
  INSERT INTO OFRECE VALUES (4053, 6016);
  INSERT INTO OFRECE VALUES (4053, 6067);
  INSERT INTO OFRECE VALUES (4053, 6084);
  INSERT INTO OFRECE VALUES (4054, 6012);
  INSERT INTO OFRECE VALUES (4054, 6014);
  INSERT INTO OFRECE VALUES (4054, 6068);
  INSERT INTO OFRECE VALUES (4055, 6011);
  INSERT INTO OFRECE VALUES (4055, 6016);
  INSERT INTO OFRECE VALUES (4055, 6062);
  INSERT INTO OFRECE VALUES (4055, 6065);
  INSERT INTO OFRECE VALUES (4056, 6015);
  INSERT INTO OFRECE VALUES (4056, 6050);
  INSERT INTO OFRECE VALUES (4056, 6063);
  INSERT INTO OFRECE VALUES (4056, 6069);
  INSERT INTO OFRECE VALUES (4057, 6011);
  INSERT INTO OFRECE VALUES (4057, 6015);
  INSERT INTO OFRECE VALUES (4057, 6066);
  INSERT INTO OFRECE VALUES (4058, 6012);
  INSERT INTO OFRECE VALUES (4058, 6015);
  INSERT INTO OFRECE VALUES (4058, 6067);
  INSERT INTO OFRECE VALUES (4058, 6075);
  INSERT INTO OFRECE VALUES (4059, 6014);
  INSERT INTO OFRECE VALUES (4059, 6015);
  INSERT INTO OFRECE VALUES (4059, 6063);
  INSERT INTO OFRECE VALUES (4059, 6083);
  INSERT INTO OFRECE VALUES (4060, 6015);
  INSERT INTO OFRECE VALUES (4060, 6050);
  INSERT INTO OFRECE VALUES (4060, 6064);
  INSERT INTO OFRECE VALUES (4060, 6076);
  INSERT INTO OFRECE VALUES (4061, 6011);
  INSERT INTO OFRECE VALUES (4061, 6014);
  INSERT INTO OFRECE VALUES (4061, 6016);
  INSERT INTO OFRECE VALUES (4061, 6061);
  INSERT INTO OFRECE VALUES (4061, 6065);
  INSERT INTO OFRECE VALUES (4062, 6013);
  INSERT INTO OFRECE VALUES (4062, 6016);
  INSERT INTO OFRECE VALUES (4062, 6063);
  INSERT INTO OFRECE VALUES (4063, 6011);
  INSERT INTO OFRECE VALUES (4063, 6013);
  INSERT INTO OFRECE VALUES (4063, 6067);
  INSERT INTO OFRECE VALUES (4063, 6074);
  INSERT INTO OFRECE VALUES (4064, 6014);
  INSERT INTO OFRECE VALUES (4064, 6050);
  INSERT INTO OFRECE VALUES (4064, 6063);
  INSERT INTO OFRECE VALUES (4064, 6067);
  INSERT INTO OFRECE VALUES (4064, 6083);
  INSERT INTO OFRECE VALUES (4065, 6012);
  INSERT INTO OFRECE VALUES (4065, 6016);
  INSERT INTO OFRECE VALUES (4065, 6050);
  INSERT INTO OFRECE VALUES (4065, 6065);
  INSERT INTO OFRECE VALUES (4066, 6013);
  INSERT INTO OFRECE VALUES (4066, 6016);
  INSERT INTO OFRECE VALUES (4066, 6066);
  INSERT INTO OFRECE VALUES (4066, 6074);
  INSERT INTO OFRECE VALUES (4067, 6012);
  INSERT INTO OFRECE VALUES (4067, 6050);
  INSERT INTO OFRECE VALUES (4067, 6065);
  INSERT INTO OFRECE VALUES (4067, 6076);
  INSERT INTO OFRECE VALUES (4068, 6012);
  INSERT INTO OFRECE VALUES (4068, 6016);
  INSERT INTO OFRECE VALUES (4068, 6050);
  INSERT INTO OFRECE VALUES (4068, 6063);
  COMMIT;
END;

BEGIN
  INSERT INTO OFRECE VALUES (4069, 6011);
  INSERT INTO OFRECE VALUES (4069, 6015);
  INSERT INTO OFRECE VALUES (4069, 6016);
  INSERT INTO OFRECE VALUES (4069, 6061);
  INSERT INTO OFRECE VALUES (4069, 6064);
  INSERT INTO OFRECE VALUES (4069, 6075);
  INSERT INTO OFRECE VALUES (4070, 6014);
  INSERT INTO OFRECE VALUES (4070, 6050);
  INSERT INTO OFRECE VALUES (4070, 6063);
  INSERT INTO OFRECE VALUES (4070, 6070);
  INSERT INTO OFRECE VALUES (4071, 6106);
  INSERT INTO OFRECE VALUES (4071, 6108);
  INSERT INTO OFRECE VALUES (4071, 6116);
  INSERT INTO OFRECE VALUES (4071, 6118);
  INSERT INTO OFRECE VALUES (4071, 6171);
  INSERT INTO OFRECE VALUES (4071, 6174);
  INSERT INTO OFRECE VALUES (4071, 6175);
  INSERT INTO OFRECE VALUES (4072, 6110);
  INSERT INTO OFRECE VALUES (4072, 6111);
  INSERT INTO OFRECE VALUES (4072, 6112);
  INSERT INTO OFRECE VALUES (4072, 6114);
  INSERT INTO OFRECE VALUES (4072, 6170);
  INSERT INTO OFRECE VALUES (4072, 6173);
  INSERT INTO OFRECE VALUES (4072, 6174);
  INSERT INTO OFRECE VALUES (4072, 6175);
  INSERT INTO OFRECE VALUES (4073, 6108);
  INSERT INTO OFRECE VALUES (4073, 6111);
  INSERT INTO OFRECE VALUES (4073, 6113);
  INSERT INTO OFRECE VALUES (4073, 6117);
  INSERT INTO OFRECE VALUES (4073, 6166);
  INSERT INTO OFRECE VALUES (4073, 6172);
  INSERT INTO OFRECE VALUES (4073, 6173);
  INSERT INTO OFRECE VALUES (4074, 6106);
  INSERT INTO OFRECE VALUES (4074, 6113);
  INSERT INTO OFRECE VALUES (4074, 6124);
  INSERT INTO OFRECE VALUES (4074, 6125);
  INSERT INTO OFRECE VALUES (4074, 6170);
  INSERT INTO OFRECE VALUES (4074, 6176);
  INSERT INTO OFRECE VALUES (4074, 6177);
  INSERT INTO OFRECE VALUES (4075, 6109);
  INSERT INTO OFRECE VALUES (4075, 6117);
  INSERT INTO OFRECE VALUES (4075, 6122);
  INSERT INTO OFRECE VALUES (4075, 6125);
  INSERT INTO OFRECE VALUES (4075, 6167);
  INSERT INTO OFRECE VALUES (4075, 6174);
  INSERT INTO OFRECE VALUES (4075, 6175);
  INSERT INTO OFRECE VALUES (4076, 6112);
  INSERT INTO OFRECE VALUES (4076, 6113);
  INSERT INTO OFRECE VALUES (4076, 6115);
  INSERT INTO OFRECE VALUES (4076, 6121);
  INSERT INTO OFRECE VALUES (4076, 6166);
  INSERT INTO OFRECE VALUES (4076, 6167);
  INSERT INTO OFRECE VALUES (4076, 6173);
  INSERT INTO OFRECE VALUES (4077, 6107);
  INSERT INTO OFRECE VALUES (4077, 6115);
  INSERT INTO OFRECE VALUES (4077, 6117);
  INSERT INTO OFRECE VALUES (4077, 6123);
  INSERT INTO OFRECE VALUES (4077, 6168);
  INSERT INTO OFRECE VALUES (4077, 6176);
  INSERT INTO OFRECE VALUES (4078, 6107);
  INSERT INTO OFRECE VALUES (4078, 6114);
  INSERT INTO OFRECE VALUES (4078, 6119);
  INSERT INTO OFRECE VALUES (4078, 6121);
  INSERT INTO OFRECE VALUES (4078, 6123);
  INSERT INTO OFRECE VALUES (4078, 6168);
  INSERT INTO OFRECE VALUES (4078, 6174);
  INSERT INTO OFRECE VALUES (4078, 6175);
  INSERT INTO OFRECE VALUES (4079, 6106);
  INSERT INTO OFRECE VALUES (4079, 6110);
  INSERT INTO OFRECE VALUES (4079, 6122);
  INSERT INTO OFRECE VALUES (4079, 6124);
  INSERT INTO OFRECE VALUES (4079, 6166);
  INSERT INTO OFRECE VALUES (4079, 6167);
  INSERT INTO OFRECE VALUES (4080, 6109);
  INSERT INTO OFRECE VALUES (4080, 6114);
  INSERT INTO OFRECE VALUES (4080, 6115);
  INSERT INTO OFRECE VALUES (4080, 6122);
  INSERT INTO OFRECE VALUES (4080, 6124);
  INSERT INTO OFRECE VALUES (4080, 6171);
  INSERT INTO OFRECE VALUES (4081, 6106);
  INSERT INTO OFRECE VALUES (4081, 6113);
  INSERT INTO OFRECE VALUES (4081, 6118);
  INSERT INTO OFRECE VALUES (4081, 6125);
  INSERT INTO OFRECE VALUES (4081, 6167);
  INSERT INTO OFRECE VALUES (4081, 6169);
  INSERT INTO OFRECE VALUES (4082, 6111);
  INSERT INTO OFRECE VALUES (4082, 6118);
  INSERT INTO OFRECE VALUES (4082, 6119);
  INSERT INTO OFRECE VALUES (4082, 6123);
  INSERT INTO OFRECE VALUES (4082, 6167);
  INSERT INTO OFRECE VALUES (4082, 6172);
  INSERT INTO OFRECE VALUES (4083, 6109);
  INSERT INTO OFRECE VALUES (4083, 6112);
  INSERT INTO OFRECE VALUES (4083, 6116);
  INSERT INTO OFRECE VALUES (4083, 6125);
  INSERT INTO OFRECE VALUES (4083, 6170);
  INSERT INTO OFRECE VALUES (4083, 6172);
  INSERT INTO OFRECE VALUES (4083, 6176);
  INSERT INTO OFRECE VALUES (4084, 6106);
  INSERT INTO OFRECE VALUES (4084, 6110);
  INSERT INTO OFRECE VALUES (4084, 6115);
  INSERT INTO OFRECE VALUES (4084, 6124);
  INSERT INTO OFRECE VALUES (4084, 6173);
  INSERT INTO OFRECE VALUES (4084, 6174);
  INSERT INTO OFRECE VALUES (4085, 6114);
  INSERT INTO OFRECE VALUES (4085, 6116);
  INSERT INTO OFRECE VALUES (4085, 6118);
  INSERT INTO OFRECE VALUES (4085, 6120);
  INSERT INTO OFRECE VALUES (4085, 6167);
  INSERT INTO OFRECE VALUES (4085, 6169);
  INSERT INTO OFRECE VALUES (4085, 6171);
  INSERT INTO OFRECE VALUES (4086, 6109);
  INSERT INTO OFRECE VALUES (4086, 6110);
  INSERT INTO OFRECE VALUES (4086, 6120);
  INSERT INTO OFRECE VALUES (4086, 6124);
  INSERT INTO OFRECE VALUES (4086, 6169);
  INSERT INTO OFRECE VALUES (4086, 6173);
  INSERT INTO OFRECE VALUES (4087, 6106);
  INSERT INTO OFRECE VALUES (4087, 6110);
  INSERT INTO OFRECE VALUES (4087, 6115);
  INSERT INTO OFRECE VALUES (4087, 6120);
  INSERT INTO OFRECE VALUES (4087, 6121);
  INSERT INTO OFRECE VALUES (4087, 6167);
  INSERT INTO OFRECE VALUES (4087, 6177);
  INSERT INTO OFRECE VALUES (4088, 6108);
  INSERT INTO OFRECE VALUES (4088, 6117);
  INSERT INTO OFRECE VALUES (4088, 6120);
  INSERT INTO OFRECE VALUES (4088, 6124);
  INSERT INTO OFRECE VALUES (4088, 6169);
  INSERT INTO OFRECE VALUES (4088, 6171);
  INSERT INTO OFRECE VALUES (4088, 6173);
  INSERT INTO OFRECE VALUES (4089, 6133);
  INSERT INTO OFRECE VALUES (4089, 6138);
  INSERT INTO OFRECE VALUES (4089, 6185);
  INSERT INTO OFRECE VALUES (4089, 6187);
  INSERT INTO OFRECE VALUES (4089, 6192);
  INSERT INTO OFRECE VALUES (4089, 6196);
  INSERT INTO OFRECE VALUES (4090, 6135);
  INSERT INTO OFRECE VALUES (4090, 6136);
  INSERT INTO OFRECE VALUES (4090, 6182);
  INSERT INTO OFRECE VALUES (4090, 6184);
  INSERT INTO OFRECE VALUES (4090, 6191);
  INSERT INTO OFRECE VALUES (4090, 6192);
  INSERT INTO OFRECE VALUES (4091, 6129);
  INSERT INTO OFRECE VALUES (4091, 6137);
  INSERT INTO OFRECE VALUES (4091, 6140);
  INSERT INTO OFRECE VALUES (4091, 6143);
  INSERT INTO OFRECE VALUES (4091, 6145);
  INSERT INTO OFRECE VALUES (4091, 6191);
  INSERT INTO OFRECE VALUES (4091, 6195);
  INSERT INTO OFRECE VALUES (4092, 6137);
  INSERT INTO OFRECE VALUES (4092, 6186);
  INSERT INTO OFRECE VALUES (4092, 6194);
  INSERT INTO OFRECE VALUES (4092, 6199);
  INSERT INTO OFRECE VALUES (4092, 6200);
  INSERT INTO OFRECE VALUES (4093, 6127);
  INSERT INTO OFRECE VALUES (4093, 6131);
  INSERT INTO OFRECE VALUES (4093, 6145);
  INSERT INTO OFRECE VALUES (4093, 6184);
  INSERT INTO OFRECE VALUES (4093, 6192);
  INSERT INTO OFRECE VALUES (4093, 6193);
  INSERT INTO OFRECE VALUES (4093, 6200);
  INSERT INTO OFRECE VALUES (4094, 6128);
  INSERT INTO OFRECE VALUES (4094, 6140);
  INSERT INTO OFRECE VALUES (4094, 6141);
  INSERT INTO OFRECE VALUES (4094, 6181);
  INSERT INTO OFRECE VALUES (4094, 6185);
  INSERT INTO OFRECE VALUES (4094, 6193);
  INSERT INTO OFRECE VALUES (4095, 6129);
  INSERT INTO OFRECE VALUES (4095, 6132);
  INSERT INTO OFRECE VALUES (4095, 6137);
  INSERT INTO OFRECE VALUES (4095, 6186);
  INSERT INTO OFRECE VALUES (4095, 6193);
  INSERT INTO OFRECE VALUES (4096, 6131);
  INSERT INTO OFRECE VALUES (4096, 6137);
  INSERT INTO OFRECE VALUES (4096, 6144);
  INSERT INTO OFRECE VALUES (4096, 6183);
  INSERT INTO OFRECE VALUES (4096, 6186);
  INSERT INTO OFRECE VALUES (4096, 6192);
  INSERT INTO OFRECE VALUES (4096, 6198);
  INSERT INTO OFRECE VALUES (4097, 6141);
  INSERT INTO OFRECE VALUES (4097, 6142);
  INSERT INTO OFRECE VALUES (4097, 6183);
  INSERT INTO OFRECE VALUES (4097, 6194);
  INSERT INTO OFRECE VALUES (4097, 6195);
  INSERT INTO OFRECE VALUES (4097, 6197);
  INSERT INTO OFRECE VALUES (4098, 6128);
  INSERT INTO OFRECE VALUES (4098, 6129);
  INSERT INTO OFRECE VALUES (4098, 6140);
  INSERT INTO OFRECE VALUES (4098, 6145);
  INSERT INTO OFRECE VALUES (4098, 6187);
  INSERT INTO OFRECE VALUES (4098, 6188);
  INSERT INTO OFRECE VALUES (4099, 6129);
  INSERT INTO OFRECE VALUES (4099, 6135);
  INSERT INTO OFRECE VALUES (4099, 6182);
  INSERT INTO OFRECE VALUES (4099, 6185);
  INSERT INTO OFRECE VALUES (4099, 6196);
  INSERT INTO OFRECE VALUES (4099, 6198);
  INSERT INTO OFRECE VALUES (4100, 6137);
  INSERT INTO OFRECE VALUES (4100, 6142);
  INSERT INTO OFRECE VALUES (4100, 6178);
  INSERT INTO OFRECE VALUES (4100, 6181);
  INSERT INTO OFRECE VALUES (4100, 6182);
  INSERT INTO OFRECE VALUES (4100, 6192);
  INSERT INTO OFRECE VALUES (4100, 6199);
  INSERT INTO OFRECE VALUES (4101, 6135);
  INSERT INTO OFRECE VALUES (4101, 6140);
  INSERT INTO OFRECE VALUES (4101, 6145);
  INSERT INTO OFRECE VALUES (4101, 6178);
  INSERT INTO OFRECE VALUES (4101, 6181);
  INSERT INTO OFRECE VALUES (4101, 6194);
  INSERT INTO OFRECE VALUES (4102, 6136);
  INSERT INTO OFRECE VALUES (4102, 6140);
  INSERT INTO OFRECE VALUES (4102, 6144);
  INSERT INTO OFRECE VALUES (4102, 6179);
  INSERT INTO OFRECE VALUES (4102, 6188);
  INSERT INTO OFRECE VALUES (4102, 6198);
  INSERT INTO OFRECE VALUES (4103, 6129);
  INSERT INTO OFRECE VALUES (4103, 6130);
  INSERT INTO OFRECE VALUES (4103, 6134);
  INSERT INTO OFRECE VALUES (4103, 6141);
  INSERT INTO OFRECE VALUES (4103, 6182);
  INSERT INTO OFRECE VALUES (4103, 6191);
  INSERT INTO OFRECE VALUES (4103, 6196);
  INSERT INTO OFRECE VALUES (4104, 6132);
  INSERT INTO OFRECE VALUES (4104, 6134);
  INSERT INTO OFRECE VALUES (4104, 6182);
  INSERT INTO OFRECE VALUES (4104, 6185);
  INSERT INTO OFRECE VALUES (4104, 6186);
  INSERT INTO OFRECE VALUES (4105, 6129);
  INSERT INTO OFRECE VALUES (4105, 6140);
  INSERT INTO OFRECE VALUES (4105, 6141);
  INSERT INTO OFRECE VALUES (4105, 6179);
  INSERT INTO OFRECE VALUES (4105, 6186);
  INSERT INTO OFRECE VALUES (4106, 6127);
  INSERT INTO OFRECE VALUES (4106, 6132);
  INSERT INTO OFRECE VALUES (4106, 6134);
  INSERT INTO OFRECE VALUES (4106, 6180);
  INSERT INTO OFRECE VALUES (4106, 6195);
  INSERT INTO OFRECE VALUES (4107, 6126);
  INSERT INTO OFRECE VALUES (4107, 6138);
  INSERT INTO OFRECE VALUES (4107, 6157);
  INSERT INTO OFRECE VALUES (4107, 6160);
  INSERT INTO OFRECE VALUES (4108, 6136);
  INSERT INTO OFRECE VALUES (4108, 6145);
  INSERT INTO OFRECE VALUES (4108, 6157);
  INSERT INTO OFRECE VALUES (4108, 6165);
  INSERT INTO OFRECE VALUES (4109, 6128);
  INSERT INTO OFRECE VALUES (4109, 6142);
  INSERT INTO OFRECE VALUES (4109, 6149);
  INSERT INTO OFRECE VALUES (4109, 6157);
  INSERT INTO OFRECE VALUES (4109, 6164);
  INSERT INTO OFRECE VALUES (4110, 6141);
  INSERT INTO OFRECE VALUES (4110, 6142);
  INSERT INTO OFRECE VALUES (4110, 6148);
  INSERT INTO OFRECE VALUES (4110, 6162);
  INSERT INTO OFRECE VALUES (4111, 6129);
  INSERT INTO OFRECE VALUES (4111, 6141);
  INSERT INTO OFRECE VALUES (4111, 6147);
  INSERT INTO OFRECE VALUES (4111, 6162);
  INSERT INTO OFRECE VALUES (4112, 6129);
  INSERT INTO OFRECE VALUES (4112, 6131);
  INSERT INTO OFRECE VALUES (4112, 6144);
  INSERT INTO OFRECE VALUES (4112, 6152);
  INSERT INTO OFRECE VALUES (4112, 6155);
  INSERT INTO OFRECE VALUES (4113, 6023);
  INSERT INTO OFRECE VALUES (4113, 6025);
  INSERT INTO OFRECE VALUES (4113, 6030);
  INSERT INTO OFRECE VALUES (4113, 6061);
  INSERT INTO OFRECE VALUES (4113, 6062);
  INSERT INTO OFRECE VALUES (4114, 6021);
  INSERT INTO OFRECE VALUES (4114, 6023);
  INSERT INTO OFRECE VALUES (4114, 6028);
  INSERT INTO OFRECE VALUES (4114, 6063);
  INSERT INTO OFRECE VALUES (4114, 6068);
  INSERT INTO OFRECE VALUES (4115, 6022);
  INSERT INTO OFRECE VALUES (4115, 6026);
  INSERT INTO OFRECE VALUES (4115, 6030);
  INSERT INTO OFRECE VALUES (4115, 6064);
  INSERT INTO OFRECE VALUES (4115, 6066);
  INSERT INTO OFRECE VALUES (4115, 6083);
  INSERT INTO OFRECE VALUES (4116, 6024);
  INSERT INTO OFRECE VALUES (4116, 6028);
  INSERT INTO OFRECE VALUES (4116, 6029);
  INSERT INTO OFRECE VALUES (4116, 6061);
  INSERT INTO OFRECE VALUES (4116, 6062);
  INSERT INTO OFRECE VALUES (4116, 6068);
  INSERT INTO OFRECE VALUES (4117, 6023);
  INSERT INTO OFRECE VALUES (4117, 6026);
  INSERT INTO OFRECE VALUES (4117, 6028);
  INSERT INTO OFRECE VALUES (4117, 6030);
  INSERT INTO OFRECE VALUES (4117, 6062);
  INSERT INTO OFRECE VALUES (4117, 6067);
  INSERT INTO OFRECE VALUES (4118, 6022);
  INSERT INTO OFRECE VALUES (4118, 6025);
  INSERT INTO OFRECE VALUES (4118, 6029);
  INSERT INTO OFRECE VALUES (4118, 6063);
  INSERT INTO OFRECE VALUES (4118, 6066);
  COMMIT;
END;

BEGIN
  INSERT INTO OFRECE VALUES (4119, 6025);
  INSERT INTO OFRECE VALUES (4119, 6026);
  INSERT INTO OFRECE VALUES (4119, 6027);
  INSERT INTO OFRECE VALUES (4119, 6066);
  INSERT INTO OFRECE VALUES (4119, 6084);
  INSERT INTO OFRECE VALUES (4120, 6026);
  INSERT INTO OFRECE VALUES (4120, 6028);
  INSERT INTO OFRECE VALUES (4120, 6029);
  INSERT INTO OFRECE VALUES (4120, 6065);
  INSERT INTO OFRECE VALUES (4120, 6069);
  INSERT INTO OFRECE VALUES (4121, 6026);
  INSERT INTO OFRECE VALUES (4121, 6027);
  INSERT INTO OFRECE VALUES (4121, 6029);
  INSERT INTO OFRECE VALUES (4121, 6063);
  INSERT INTO OFRECE VALUES (4121, 6068);
  INSERT INTO OFRECE VALUES (4122, 6021);
  INSERT INTO OFRECE VALUES (4122, 6023);
  INSERT INTO OFRECE VALUES (4122, 6028);
  INSERT INTO OFRECE VALUES (4122, 6066);
  INSERT INTO OFRECE VALUES (4122, 6084);
  INSERT INTO OFRECE VALUES (4123, 6023);
  INSERT INTO OFRECE VALUES (4123, 6024);
  INSERT INTO OFRECE VALUES (4123, 6030);
  INSERT INTO OFRECE VALUES (4123, 6067);
  INSERT INTO OFRECE VALUES (4123, 6084);
  INSERT INTO OFRECE VALUES (4124, 6023);
  INSERT INTO OFRECE VALUES (4124, 6026);
  INSERT INTO OFRECE VALUES (4124, 6027);
  INSERT INTO OFRECE VALUES (4124, 6061);
  INSERT INTO OFRECE VALUES (4124, 6085);
  INSERT INTO OFRECE VALUES (4125, 6021);
  INSERT INTO OFRECE VALUES (4125, 6024);
  INSERT INTO OFRECE VALUES (4125, 6027);
  INSERT INTO OFRECE VALUES (4125, 6028);
  INSERT INTO OFRECE VALUES (4125, 6061);
  INSERT INTO OFRECE VALUES (4125, 6067);
  INSERT INTO OFRECE VALUES (4126, 6023);
  INSERT INTO OFRECE VALUES (4126, 6028);
  INSERT INTO OFRECE VALUES (4126, 6030);
  INSERT INTO OFRECE VALUES (4126, 6063);
  INSERT INTO OFRECE VALUES (4127, 6033);
  INSERT INTO OFRECE VALUES (4127, 6035);
  INSERT INTO OFRECE VALUES (4127, 6039);
  INSERT INTO OFRECE VALUES (4127, 6065);
  INSERT INTO OFRECE VALUES (4127, 6069);
  INSERT INTO OFRECE VALUES (4128, 6033);
  INSERT INTO OFRECE VALUES (4128, 6035);
  INSERT INTO OFRECE VALUES (4128, 6037);
  INSERT INTO OFRECE VALUES (4128, 6038);
  INSERT INTO OFRECE VALUES (4128, 6065);
  INSERT INTO OFRECE VALUES (4128, 6083);
  INSERT INTO OFRECE VALUES (4129, 6035);
  INSERT INTO OFRECE VALUES (4129, 6037);
  INSERT INTO OFRECE VALUES (4129, 6039);
  INSERT INTO OFRECE VALUES (4129, 6062);
  INSERT INTO OFRECE VALUES (4129, 6066);
  INSERT INTO OFRECE VALUES (4130, 6032);
  INSERT INTO OFRECE VALUES (4130, 6037);
  INSERT INTO OFRECE VALUES (4130, 6038);
  INSERT INTO OFRECE VALUES (4130, 6040);
  INSERT INTO OFRECE VALUES (4130, 6062);
  INSERT INTO OFRECE VALUES (4131, 6034);
  INSERT INTO OFRECE VALUES (4131, 6038);
  INSERT INTO OFRECE VALUES (4131, 6040);
  INSERT INTO OFRECE VALUES (4131, 6066);
  INSERT INTO OFRECE VALUES (4131, 6070);
  INSERT INTO OFRECE VALUES (4132, 6036);
  INSERT INTO OFRECE VALUES (4132, 6039);
  INSERT INTO OFRECE VALUES (4132, 6040);
  INSERT INTO OFRECE VALUES (4132, 6064);
  INSERT INTO OFRECE VALUES (4132, 6068);
  INSERT INTO OFRECE VALUES (4133, 6034);
  INSERT INTO OFRECE VALUES (4133, 6035);
  INSERT INTO OFRECE VALUES (4133, 6036);
  INSERT INTO OFRECE VALUES (4133, 6037);
  INSERT INTO OFRECE VALUES (4133, 6064);
  INSERT INTO OFRECE VALUES (4133, 6066);
  INSERT INTO OFRECE VALUES (4134, 6031);
  INSERT INTO OFRECE VALUES (4134, 6035);
  INSERT INTO OFRECE VALUES (4134, 6036);
  INSERT INTO OFRECE VALUES (4134, 6066);
  INSERT INTO OFRECE VALUES (4134, 6070);
  INSERT INTO OFRECE VALUES (4134, 6083);
  INSERT INTO OFRECE VALUES (4135, 6034);
  INSERT INTO OFRECE VALUES (4135, 6036);
  INSERT INTO OFRECE VALUES (4135, 6040);
  INSERT INTO OFRECE VALUES (4135, 6061);
  INSERT INTO OFRECE VALUES (4135, 6067);
  INSERT INTO OFRECE VALUES (4136, 6031);
  INSERT INTO OFRECE VALUES (4136, 6033);
  INSERT INTO OFRECE VALUES (4136, 6038);
  INSERT INTO OFRECE VALUES (4136, 6068);
  INSERT INTO OFRECE VALUES (4136, 6084);
  INSERT INTO OFRECE VALUES (4137, 6031);
  INSERT INTO OFRECE VALUES (4137, 6035);
  INSERT INTO OFRECE VALUES (4137, 6036);
  INSERT INTO OFRECE VALUES (4137, 6040);
  INSERT INTO OFRECE VALUES (4137, 6061);
  INSERT INTO OFRECE VALUES (4137, 6069);
  INSERT INTO OFRECE VALUES (4138, 6033);
  INSERT INTO OFRECE VALUES (4138, 6036);
  INSERT INTO OFRECE VALUES (4138, 6037);
  INSERT INTO OFRECE VALUES (4138, 6062);
  INSERT INTO OFRECE VALUES (4138, 6084);
  INSERT INTO OFRECE VALUES (4139, 6036);
  INSERT INTO OFRECE VALUES (4139, 6037);
  INSERT INTO OFRECE VALUES (4139, 6040);
  INSERT INTO OFRECE VALUES (4139, 6061);
  INSERT INTO OFRECE VALUES (4139, 6063);
  INSERT INTO OFRECE VALUES (4140, 6051);
  INSERT INTO OFRECE VALUES (4140, 6052);
  INSERT INTO OFRECE VALUES (4140, 6058);
  INSERT INTO OFRECE VALUES (4140, 6060);
  INSERT INTO OFRECE VALUES (4140, 6068);
  INSERT INTO OFRECE VALUES (4141, 6052);
  INSERT INTO OFRECE VALUES (4141, 6053);
  INSERT INTO OFRECE VALUES (4141, 6054);
  INSERT INTO OFRECE VALUES (4141, 6062);
  INSERT INTO OFRECE VALUES (4142, 6056);
  INSERT INTO OFRECE VALUES (4142, 6058);
  INSERT INTO OFRECE VALUES (4142, 6059);
  INSERT INTO OFRECE VALUES (4142, 6068);
  INSERT INTO OFRECE VALUES (4143, 6051);
  INSERT INTO OFRECE VALUES (4143, 6057);
  INSERT INTO OFRECE VALUES (4143, 6059);
  INSERT INTO OFRECE VALUES (4143, 6062);
  INSERT INTO OFRECE VALUES (4144, 6056);
  INSERT INTO OFRECE VALUES (4144, 6058);
  INSERT INTO OFRECE VALUES (4144, 6059);
  INSERT INTO OFRECE VALUES (4144, 6061);
  INSERT INTO OFRECE VALUES (4144, 6084);
  INSERT INTO OFRECE VALUES (4145, 6051);
  INSERT INTO OFRECE VALUES (4145, 6053);
  INSERT INTO OFRECE VALUES (4145, 6056);
  INSERT INTO OFRECE VALUES (4145, 6064);
  INSERT INTO OFRECE VALUES (4146, 6053);
  INSERT INTO OFRECE VALUES (4146, 6054);
  INSERT INTO OFRECE VALUES (4146, 6060);
  INSERT INTO OFRECE VALUES (4146, 6064);
  INSERT INTO OFRECE VALUES (4147, 6053);
  INSERT INTO OFRECE VALUES (4147, 6054);
  INSERT INTO OFRECE VALUES (4147, 6058);
  INSERT INTO OFRECE VALUES (4147, 6059);
  INSERT INTO OFRECE VALUES (4147, 6063);
  INSERT INTO OFRECE VALUES (4148, 6051);
  INSERT INTO OFRECE VALUES (4148, 6054);
  INSERT INTO OFRECE VALUES (4148, 6055);
  INSERT INTO OFRECE VALUES (4148, 6064);
  INSERT INTO OFRECE VALUES (4148, 6068);
  INSERT INTO OFRECE VALUES (4149, 6056);
  INSERT INTO OFRECE VALUES (4149, 6057);
  INSERT INTO OFRECE VALUES (4149, 6060);
  INSERT INTO OFRECE VALUES (4149, 6062);
  INSERT INTO OFRECE VALUES (4150, 6054);
  INSERT INTO OFRECE VALUES (4150, 6055);
  INSERT INTO OFRECE VALUES (4150, 6058);
  INSERT INTO OFRECE VALUES (4150, 6064);
  INSERT INTO OFRECE VALUES (4151, 6052);
  INSERT INTO OFRECE VALUES (4151, 6053);
  INSERT INTO OFRECE VALUES (4151, 6058);
  INSERT INTO OFRECE VALUES (4151, 6060);
  INSERT INTO OFRECE VALUES (4151, 6062);
  INSERT INTO OFRECE VALUES (4152, 6054);
  INSERT INTO OFRECE VALUES (4152, 6057);
  INSERT INTO OFRECE VALUES (4152, 6058);
  INSERT INTO OFRECE VALUES (4152, 6063);
  INSERT INTO OFRECE VALUES (4153, 6055);
  INSERT INTO OFRECE VALUES (4153, 6058);
  INSERT INTO OFRECE VALUES (4153, 6059);
  INSERT INTO OFRECE VALUES (4153, 6064);
  INSERT INTO OFRECE VALUES (4154, 6056);
  INSERT INTO OFRECE VALUES (4154, 6058);
  INSERT INTO OFRECE VALUES (4154, 6059);
  INSERT INTO OFRECE VALUES (4154, 6061);
  INSERT INTO OFRECE VALUES (4154, 6083);
  INSERT INTO OFRECE VALUES (4155, 6052);
  INSERT INTO OFRECE VALUES (4155, 6053);
  INSERT INTO OFRECE VALUES (4155, 6054);
  INSERT INTO OFRECE VALUES (4155, 6060);
  INSERT INTO OFRECE VALUES (4155, 6063);
  INSERT INTO OFRECE VALUES (4156, 6082);
  INSERT INTO OFRECE VALUES (4156, 6101);
  INSERT INTO OFRECE VALUES (4156, 6102);
  INSERT INTO OFRECE VALUES (4156, 6103);
  INSERT INTO OFRECE VALUES (4156, 6063);
  INSERT INTO OFRECE VALUES (4156, 6064);
  INSERT INTO OFRECE VALUES (4156, 6065);
  INSERT INTO OFRECE VALUES (4157, 6080);
  INSERT INTO OFRECE VALUES (4157, 6082);
  INSERT INTO OFRECE VALUES (4157, 6104);
  INSERT INTO OFRECE VALUES (4157, 6066);
  INSERT INTO OFRECE VALUES (4157, 6083);
  INSERT INTO OFRECE VALUES (4158, 6080);
  INSERT INTO OFRECE VALUES (4158, 6081);
  INSERT INTO OFRECE VALUES (4158, 6104);
  INSERT INTO OFRECE VALUES (4158, 6105);
  INSERT INTO OFRECE VALUES (4158, 6063);
  INSERT INTO OFRECE VALUES (4158, 6065);
  INSERT INTO OFRECE VALUES (4158, 6085);
  INSERT INTO OFRECE VALUES (4159, 6080);
  INSERT INTO OFRECE VALUES (4159, 6081);
  INSERT INTO OFRECE VALUES (4159, 6101);
  INSERT INTO OFRECE VALUES (4159, 6104);
  INSERT INTO OFRECE VALUES (4159, 6061);
  INSERT INTO OFRECE VALUES (4159, 6069);
  INSERT INTO OFRECE VALUES (4160, 6081);
  INSERT INTO OFRECE VALUES (4160, 6103);
  INSERT INTO OFRECE VALUES (4160, 6104);
  INSERT INTO OFRECE VALUES (4160, 6061);
  INSERT INTO OFRECE VALUES (4160, 6065);
  INSERT INTO OFRECE VALUES (4160, 6067);
  INSERT INTO OFRECE VALUES (4161, 6080);
  INSERT INTO OFRECE VALUES (4161, 6101);
  INSERT INTO OFRECE VALUES (4161, 6104);
  INSERT INTO OFRECE VALUES (4161, 6067);
  INSERT INTO OFRECE VALUES (4161, 6069);
  INSERT INTO OFRECE VALUES (4161, 6083);
  INSERT INTO OFRECE VALUES (4162, 6080);
  INSERT INTO OFRECE VALUES (4162, 6103);
  INSERT INTO OFRECE VALUES (4162, 6104);
  INSERT INTO OFRECE VALUES (4162, 6064);
  INSERT INTO OFRECE VALUES (4162, 6068);
  INSERT INTO OFRECE VALUES (4163, 6080);
  INSERT INTO OFRECE VALUES (4163, 6082);
  INSERT INTO OFRECE VALUES (4163, 6103);
  INSERT INTO OFRECE VALUES (4163, 6062);
  INSERT INTO OFRECE VALUES (4163, 6066);
  INSERT INTO OFRECE VALUES (4163, 6068);
  INSERT INTO OFRECE VALUES (4164, 6080);
  INSERT INTO OFRECE VALUES (4164, 6101);
  INSERT INTO OFRECE VALUES (4164, 6102);
  INSERT INTO OFRECE VALUES (4164, 6103);
  INSERT INTO OFRECE VALUES (4164, 6062);
  INSERT INTO OFRECE VALUES (4164, 6063);
  INSERT INTO OFRECE VALUES (4165, 6081);
  INSERT INTO OFRECE VALUES (4165, 6101);
  INSERT INTO OFRECE VALUES (4165, 6102);
  INSERT INTO OFRECE VALUES (4165, 6104);
  INSERT INTO OFRECE VALUES (4165, 6062);
  COMMIT;
END;

BEGIN
  INSERT INTO OFRECE VALUES (4165, 6066);
  INSERT INTO OFRECE VALUES (4166, 6081);
  INSERT INTO OFRECE VALUES (4166, 6101);
  INSERT INTO OFRECE VALUES (4166, 6102);
  INSERT INTO OFRECE VALUES (4166, 6105);
  INSERT INTO OFRECE VALUES (4166, 6065);
  INSERT INTO OFRECE VALUES (4166, 6067);
  INSERT INTO OFRECE VALUES (4166, 6068);
  INSERT INTO OFRECE VALUES (4167, 6080);
  INSERT INTO OFRECE VALUES (4167, 6104);
  INSERT INTO OFRECE VALUES (4167, 6105);
  INSERT INTO OFRECE VALUES (4167, 6061);
  INSERT INTO OFRECE VALUES (4167, 6066);
  INSERT INTO OFRECE VALUES (4167, 6083);
  INSERT INTO OFRECE VALUES (4168, 6081);
  INSERT INTO OFRECE VALUES (4168, 6082);
  INSERT INTO OFRECE VALUES (4168, 6101);
  INSERT INTO OFRECE VALUES (4168, 6067);
  INSERT INTO OFRECE VALUES (4168, 6069);
  INSERT INTO OFRECE VALUES (4168, 6070);
  INSERT INTO OFRECE VALUES (4169, 6146);
  INSERT INTO OFRECE VALUES (4169, 6147);
  INSERT INTO OFRECE VALUES (4169, 6157);
  INSERT INTO OFRECE VALUES (4169, 6164);
  INSERT INTO OFRECE VALUES (4169, 6165);
  INSERT INTO OFRECE VALUES (4170, 6150);
  INSERT INTO OFRECE VALUES (4170, 6151);
  INSERT INTO OFRECE VALUES (4170, 6153);
  INSERT INTO OFRECE VALUES (4170, 6159);
  INSERT INTO OFRECE VALUES (4170, 6165);
  INSERT INTO OFRECE VALUES (4171, 6148);
  INSERT INTO OFRECE VALUES (4171, 6153);
  INSERT INTO OFRECE VALUES (4171, 6155);
  INSERT INTO OFRECE VALUES (4171, 6161);
  INSERT INTO OFRECE VALUES (4172, 6151);
  INSERT INTO OFRECE VALUES (4172, 6153);
  INSERT INTO OFRECE VALUES (4172, 6154);
  INSERT INTO OFRECE VALUES (4172, 6164);
  INSERT INTO OFRECE VALUES (4173, 6154);
  INSERT INTO OFRECE VALUES (4173, 6155);
  INSERT INTO OFRECE VALUES (4173, 6157);
  INSERT INTO OFRECE VALUES (4173, 6160);
  INSERT INTO OFRECE VALUES (4174, 6146);
  INSERT INTO OFRECE VALUES (4174, 6147);
  INSERT INTO OFRECE VALUES (4174, 6150);
  INSERT INTO OFRECE VALUES (4174, 6161);
  INSERT INTO OFRECE VALUES (4174, 6165);
  INSERT INTO OFRECE VALUES (4175, 6149);
  INSERT INTO OFRECE VALUES (4175, 6151);
  INSERT INTO OFRECE VALUES (4175, 6153);
  INSERT INTO OFRECE VALUES (4175, 6158);
  INSERT INTO OFRECE VALUES (4176, 6148);
  INSERT INTO OFRECE VALUES (4176, 6151);
  INSERT INTO OFRECE VALUES (4176, 6162);
  INSERT INTO OFRECE VALUES (4176, 6164);
  INSERT INTO OFRECE VALUES (4177, 6147);
  INSERT INTO OFRECE VALUES (4177, 6156);
  INSERT INTO OFRECE VALUES (4177, 6157);
  INSERT INTO OFRECE VALUES (4177, 6162);
  INSERT INTO OFRECE VALUES (4178, 6146);
  INSERT INTO OFRECE VALUES (4178, 6148);
  INSERT INTO OFRECE VALUES (4178, 6153);
  INSERT INTO OFRECE VALUES (4178, 6156);
  INSERT INTO OFRECE VALUES (4178, 6161);
  INSERT INTO OFRECE VALUES (4179, 6151);
  INSERT INTO OFRECE VALUES (4179, 6158);
  INSERT INTO OFRECE VALUES (4179, 6161);
  INSERT INTO OFRECE VALUES (4179, 6162);
  INSERT INTO OFRECE VALUES (4180, 6003);
  INSERT INTO OFRECE VALUES (4180, 6007);
  INSERT INTO OFRECE VALUES (4180, 6008);
  INSERT INTO OFRECE VALUES (4180, 6010);
  INSERT INTO OFRECE VALUES (4180, 6062);
  INSERT INTO OFRECE VALUES (4180, 6067);
  INSERT INTO OFRECE VALUES (4181, 6002);
  INSERT INTO OFRECE VALUES (4181, 6003);
  INSERT INTO OFRECE VALUES (4181, 6009);
  INSERT INTO OFRECE VALUES (4181, 6067);
  INSERT INTO OFRECE VALUES (4181, 6083);
  INSERT INTO OFRECE VALUES (4182, 6006);
  INSERT INTO OFRECE VALUES (4182, 6007);
  INSERT INTO OFRECE VALUES (4182, 6009);
  INSERT INTO OFRECE VALUES (4182, 6061);
  INSERT INTO OFRECE VALUES (4182, 6063);
  INSERT INTO OFRECE VALUES (4183, 6043);
  INSERT INTO OFRECE VALUES (4183, 6046);
  INSERT INTO OFRECE VALUES (4183, 6048);
  INSERT INTO OFRECE VALUES (4183, 6059);
  INSERT INTO OFRECE VALUES (4183, 6065);
  INSERT INTO OFRECE VALUES (4184, 6011);
  INSERT INTO OFRECE VALUES (4184, 6014);
  INSERT INTO OFRECE VALUES (4184, 6050);
  INSERT INTO OFRECE VALUES (4184, 6062);
  INSERT INTO OFRECE VALUES (4184, 6064);
  COMMIT;
END;

BEGIN
  INSERT INTO OFRECE VALUES (4185, 6012);
  INSERT INTO OFRECE VALUES (4185, 6016);
  INSERT INTO OFRECE VALUES (4185, 6061);
  INSERT INTO OFRECE VALUES (4185, 6066);
  INSERT INTO OFRECE VALUES (4186, 6108);
  INSERT INTO OFRECE VALUES (4186, 6112);
  INSERT INTO OFRECE VALUES (4186, 6117);
  INSERT INTO OFRECE VALUES (4186, 6118);
  INSERT INTO OFRECE VALUES (4186, 6121);
  INSERT INTO OFRECE VALUES (4186, 6167);
  INSERT INTO OFRECE VALUES (4186, 6171);
  INSERT INTO OFRECE VALUES (4186, 6174);
  INSERT INTO OFRECE VALUES (4186, 6176);
  INSERT INTO OFRECE VALUES (4187, 6107);
  INSERT INTO OFRECE VALUES (4187, 6114);
  INSERT INTO OFRECE VALUES (4187, 6115);
  INSERT INTO OFRECE VALUES (4187, 6119);
  INSERT INTO OFRECE VALUES (4187, 6120);
  INSERT INTO OFRECE VALUES (4187, 6123);
  INSERT INTO OFRECE VALUES (4187, 6169);
  INSERT INTO OFRECE VALUES (4187, 6172);
  INSERT INTO OFRECE VALUES (4187, 6173);
  INSERT INTO OFRECE VALUES (4187, 6174);
  INSERT INTO OFRECE VALUES (4188, 6108);
  INSERT INTO OFRECE VALUES (4188, 6112);
  INSERT INTO OFRECE VALUES (4188, 6114);
  INSERT INTO OFRECE VALUES (4188, 6115);
  INSERT INTO OFRECE VALUES (4188, 6123);
  INSERT INTO OFRECE VALUES (4188, 6169);
  INSERT INTO OFRECE VALUES (4188, 6171);
  INSERT INTO OFRECE VALUES (4188, 6173);
  INSERT INTO OFRECE VALUES (4189, 6109);
  INSERT INTO OFRECE VALUES (4189, 6113);
  INSERT INTO OFRECE VALUES (4189, 6120);
  INSERT INTO OFRECE VALUES (4189, 6121);
  INSERT INTO OFRECE VALUES (4189, 6122);
  INSERT INTO OFRECE VALUES (4189, 6125);
  INSERT INTO OFRECE VALUES (4189, 6167);
  INSERT INTO OFRECE VALUES (4189, 6168);
  INSERT INTO OFRECE VALUES (4189, 6170);
  INSERT INTO OFRECE VALUES (4189, 6173);
  INSERT INTO OFRECE VALUES (4190, 6127);
  INSERT INTO OFRECE VALUES (4190, 6131);
  INSERT INTO OFRECE VALUES (4190, 6135);
  INSERT INTO OFRECE VALUES (4190, 6137);
  INSERT INTO OFRECE VALUES (4190, 6140);
  INSERT INTO OFRECE VALUES (4190, 6144);
  INSERT INTO OFRECE VALUES (4190, 6145);
  INSERT INTO OFRECE VALUES (4190, 6185);
  INSERT INTO OFRECE VALUES (4190, 6187);
  INSERT INTO OFRECE VALUES (4190, 6189);
  INSERT INTO OFRECE VALUES (4190, 6197);
  INSERT INTO OFRECE VALUES (4190, 6200);
  INSERT INTO OFRECE VALUES (4191, 6128);
  INSERT INTO OFRECE VALUES (4191, 6130);
  INSERT INTO OFRECE VALUES (4191, 6134);
  INSERT INTO OFRECE VALUES (4191, 6135);
  INSERT INTO OFRECE VALUES (4191, 6136);
  INSERT INTO OFRECE VALUES (4191, 6144);
  INSERT INTO OFRECE VALUES (4191, 6145);
  INSERT INTO OFRECE VALUES (4191, 6179);
  INSERT INTO OFRECE VALUES (4191, 6184);
  INSERT INTO OFRECE VALUES (4191, 6188);
  INSERT INTO OFRECE VALUES (4191, 6189);
  INSERT INTO OFRECE VALUES (4192, 6127);
  INSERT INTO OFRECE VALUES (4192, 6130);
  INSERT INTO OFRECE VALUES (4192, 6134);
  INSERT INTO OFRECE VALUES (4192, 6136);
  INSERT INTO OFRECE VALUES (4192, 6138);
  INSERT INTO OFRECE VALUES (4192, 6143);
  INSERT INTO OFRECE VALUES (4192, 6186);
  INSERT INTO OFRECE VALUES (4192, 6195);
  INSERT INTO OFRECE VALUES (4192, 6197);
  COMMIT;
END;

BEGIN
  INSERT INTO OFRECE VALUES (4192, 6198);
  INSERT INTO OFRECE VALUES (4193, 6129);
  INSERT INTO OFRECE VALUES (4193, 6132);
  INSERT INTO OFRECE VALUES (4193, 6134);
  INSERT INTO OFRECE VALUES (4193, 6138);
  INSERT INTO OFRECE VALUES (4193, 6141);
  INSERT INTO OFRECE VALUES (4193, 6144);
  INSERT INTO OFRECE VALUES (4193, 6182);
  INSERT INTO OFRECE VALUES (4193, 6186);
  INSERT INTO OFRECE VALUES (4193, 6195);
  INSERT INTO OFRECE VALUES (4193, 6198);
  INSERT INTO OFRECE VALUES (4194, 6023);
  INSERT INTO OFRECE VALUES (4194, 6025);
  INSERT INTO OFRECE VALUES (4194, 6029);
  INSERT INTO OFRECE VALUES (4194, 6061);
  INSERT INTO OFRECE VALUES (4194, 6062);
  INSERT INTO OFRECE VALUES (4194, 6085);
  INSERT INTO OFRECE VALUES (4195, 6032);
  INSERT INTO OFRECE VALUES (4195, 6038);
  INSERT INTO OFRECE VALUES (4195, 6040);
  INSERT INTO OFRECE VALUES (4195, 6063);
  INSERT INTO OFRECE VALUES (4195, 6069);
  INSERT INTO OFRECE VALUES (4196, 6033);
  INSERT INTO OFRECE VALUES (4196, 6035);
  INSERT INTO OFRECE VALUES (4196, 6036);
  INSERT INTO OFRECE VALUES (4196, 6062);
  INSERT INTO OFRECE VALUES (4196, 6066);
  INSERT INTO OFRECE VALUES (4196, 6083);
  INSERT INTO OFRECE VALUES (4197, 6055);
  INSERT INTO OFRECE VALUES (4197, 6056);
  INSERT INTO OFRECE VALUES (4197, 6058);
  INSERT INTO OFRECE VALUES (4197, 6067);
  INSERT INTO OFRECE VALUES (4198, 6054);
  INSERT INTO OFRECE VALUES (4198, 6057);
  INSERT INTO OFRECE VALUES (4198, 6060);
  INSERT INTO OFRECE VALUES (4198, 6068);
  INSERT INTO OFRECE VALUES (4198, 6070);
  INSERT INTO OFRECE VALUES (4199, 6052);
  INSERT INTO OFRECE VALUES (4199, 6054);
  INSERT INTO OFRECE VALUES (4199, 6056);
  INSERT INTO OFRECE VALUES (4199, 6064);
  INSERT INTO OFRECE VALUES (4200, 6081);
  INSERT INTO OFRECE VALUES (4200, 6101);
  INSERT INTO OFRECE VALUES (4200, 6103);
  INSERT INTO OFRECE VALUES (4200, 6061);
  INSERT INTO OFRECE VALUES (4200, 6062);
  INSERT INTO OFRECE VALUES (4200, 6083);
  COMMIT;
END;







--SE_ASOCIA

BEGIN
INSERT INTO SE_ASOCIA VALUES (3001, 3082);
INSERT INTO SE_ASOCIA VALUES (3002, 3002);
INSERT INTO SE_ASOCIA VALUES (3002, 3003);
INSERT INTO SE_ASOCIA VALUES (3002, 3009);
INSERT INTO SE_ASOCIA VALUES (3002, 3010);
INSERT INTO SE_ASOCIA VALUES (3002, 3012);
INSERT INTO SE_ASOCIA VALUES (3002, 3015);
INSERT INTO SE_ASOCIA VALUES (3002, 3020);
INSERT INTO SE_ASOCIA VALUES (3002, 3022);
INSERT INTO SE_ASOCIA VALUES (3002, 3024);
INSERT INTO SE_ASOCIA VALUES (3002, 3028);
INSERT INTO SE_ASOCIA VALUES (3002, 3032);
INSERT INTO SE_ASOCIA VALUES (3002, 3033);
INSERT INTO SE_ASOCIA VALUES (3002, 3034);
INSERT INTO SE_ASOCIA VALUES (3002, 3040);
INSERT INTO SE_ASOCIA VALUES (3002, 3042);
INSERT INTO SE_ASOCIA VALUES (3002, 3047);
INSERT INTO SE_ASOCIA VALUES (3002, 3048);
INSERT INTO SE_ASOCIA VALUES (3002, 3054);
INSERT INTO SE_ASOCIA VALUES (3002, 3060);
INSERT INTO SE_ASOCIA VALUES (3002, 3061);
INSERT INTO SE_ASOCIA VALUES (3002, 3063);
INSERT INTO SE_ASOCIA VALUES (3002, 3066);
INSERT INTO SE_ASOCIA VALUES (3002, 3073);
INSERT INTO SE_ASOCIA VALUES (3002, 3082);
INSERT INTO SE_ASOCIA VALUES (3002, 3083);
INSERT INTO SE_ASOCIA VALUES (3002, 3085);
INSERT INTO SE_ASOCIA VALUES (3002, 3087);
INSERT INTO SE_ASOCIA VALUES (3002, 3088);
INSERT INTO SE_ASOCIA VALUES (3002, 3090);
INSERT INTO SE_ASOCIA VALUES (3002, 3095);
INSERT INTO SE_ASOCIA VALUES (3002, 3100);
INSERT INTO SE_ASOCIA VALUES (3003, 3001);
INSERT INTO SE_ASOCIA VALUES (3003, 3002);
INSERT INTO SE_ASOCIA VALUES (3003, 3012);
INSERT INTO SE_ASOCIA VALUES (3003, 3013);
INSERT INTO SE_ASOCIA VALUES (3003, 3015);
INSERT INTO SE_ASOCIA VALUES (3003, 3016);
INSERT INTO SE_ASOCIA VALUES (3003, 3017);
INSERT INTO SE_ASOCIA VALUES (3003, 3020);
INSERT INTO SE_ASOCIA VALUES (3003, 3033);
INSERT INTO SE_ASOCIA VALUES (3003, 3035);
INSERT INTO SE_ASOCIA VALUES (3003, 3042);
INSERT INTO SE_ASOCIA VALUES (3003, 3044);
INSERT INTO SE_ASOCIA VALUES (3003, 3046);
INSERT INTO SE_ASOCIA VALUES (3003, 3051);
INSERT INTO SE_ASOCIA VALUES (3003, 3057);
INSERT INTO SE_ASOCIA VALUES (3003, 3059);
INSERT INTO SE_ASOCIA VALUES (3003, 3060);
INSERT INTO SE_ASOCIA VALUES (3003, 3063);
INSERT INTO SE_ASOCIA VALUES (3003, 3064);
INSERT INTO SE_ASOCIA VALUES (3003, 3067);
INSERT INTO SE_ASOCIA VALUES (3003, 3068);
INSERT INTO SE_ASOCIA VALUES (3003, 3072);
INSERT INTO SE_ASOCIA VALUES (3003, 3073);
INSERT INTO SE_ASOCIA VALUES (3003, 3081);
INSERT INTO SE_ASOCIA VALUES (3003, 3082);
INSERT INTO SE_ASOCIA VALUES (3003, 3083);
INSERT INTO SE_ASOCIA VALUES (3003, 3084);
INSERT INTO SE_ASOCIA VALUES (3003, 3086);
INSERT INTO SE_ASOCIA VALUES (3003, 3089);
INSERT INTO SE_ASOCIA VALUES (3003, 3090);
INSERT INTO SE_ASOCIA VALUES (3003, 3097);
INSERT INTO SE_ASOCIA VALUES (3003, 3098);
INSERT INTO SE_ASOCIA VALUES (3004, 3064);
INSERT INTO SE_ASOCIA VALUES (3004, 3067);
INSERT INTO SE_ASOCIA VALUES (3005, 3028);
INSERT INTO SE_ASOCIA VALUES (3006, 3004);
INSERT INTO SE_ASOCIA VALUES (3006, 3007);
INSERT INTO SE_ASOCIA VALUES (3006, 3009);
INSERT INTO SE_ASOCIA VALUES (3006, 3011);
INSERT INTO SE_ASOCIA VALUES (3006, 3014);
INSERT INTO SE_ASOCIA VALUES (3006, 3015);
INSERT INTO SE_ASOCIA VALUES (3006, 3017);
INSERT INTO SE_ASOCIA VALUES (3006, 3019);
INSERT INTO SE_ASOCIA VALUES (3006, 3021);
INSERT INTO SE_ASOCIA VALUES (3006, 3027);
INSERT INTO SE_ASOCIA VALUES (3006, 3028);
INSERT INTO SE_ASOCIA VALUES (3006, 3031);
INSERT INTO SE_ASOCIA VALUES (3006, 3037);
INSERT INTO SE_ASOCIA VALUES (3006, 3038);
INSERT INTO SE_ASOCIA VALUES (3006, 3042);
INSERT INTO SE_ASOCIA VALUES (3006, 3044);
INSERT INTO SE_ASOCIA VALUES (3006, 3047);
INSERT INTO SE_ASOCIA VALUES (3006, 3049);
INSERT INTO SE_ASOCIA VALUES (3006, 3051);
INSERT INTO SE_ASOCIA VALUES (3006, 3053);
INSERT INTO SE_ASOCIA VALUES (3006, 3057);
INSERT INTO SE_ASOCIA VALUES (3006, 3058);
INSERT INTO SE_ASOCIA VALUES (3006, 3061);
INSERT INTO SE_ASOCIA VALUES (3006, 3063);
INSERT INTO SE_ASOCIA VALUES (3006, 3065);
INSERT INTO SE_ASOCIA VALUES (3006, 3073);
INSERT INTO SE_ASOCIA VALUES (3006, 3074);
INSERT INTO SE_ASOCIA VALUES (3006, 3075);
INSERT INTO SE_ASOCIA VALUES (3006, 3087);
INSERT INTO SE_ASOCIA VALUES (3006, 3093);
INSERT INTO SE_ASOCIA VALUES (3006, 3099);
INSERT INTO SE_ASOCIA VALUES (3007, 3071);
  COMMIT;
END;
 

BEGIN
INSERT INTO SE_ASOCIA VALUES (3008, 3039);
INSERT INTO SE_ASOCIA VALUES (3009, 3004);
INSERT INTO SE_ASOCIA VALUES (3010, 3005);
INSERT INTO SE_ASOCIA VALUES (3010, 3020);
INSERT INTO SE_ASOCIA VALUES (3010, 3023);
INSERT INTO SE_ASOCIA VALUES (3010, 3060);
INSERT INTO SE_ASOCIA VALUES (3011, 3050);
INSERT INTO SE_ASOCIA VALUES (3012, 3066);
INSERT INTO SE_ASOCIA VALUES (3013, 3014);
INSERT INTO SE_ASOCIA VALUES (3013, 3096);
INSERT INTO SE_ASOCIA VALUES (3014, 3046);
INSERT INTO SE_ASOCIA VALUES (3014, 3084);
INSERT INTO SE_ASOCIA VALUES (3015, 3051);
INSERT INTO SE_ASOCIA VALUES (3016, 3083);
INSERT INTO SE_ASOCIA VALUES (3017, 3001);
INSERT INTO SE_ASOCIA VALUES (3017, 3055);
INSERT INTO SE_ASOCIA VALUES (3017, 3064);
INSERT INTO SE_ASOCIA VALUES (3018, 3003);
INSERT INTO SE_ASOCIA VALUES (3018, 3052);
INSERT INTO SE_ASOCIA VALUES (3018, 3088);
INSERT INTO SE_ASOCIA VALUES (3019, 3075);
INSERT INTO SE_ASOCIA VALUES (3020, 3052);
INSERT INTO SE_ASOCIA VALUES (3020, 3071);
INSERT INTO SE_ASOCIA VALUES (3021, 3006);
INSERT INTO SE_ASOCIA VALUES (3021, 3034);
INSERT INTO SE_ASOCIA VALUES (3022, 3084);
INSERT INTO SE_ASOCIA VALUES (3023, 3052);
INSERT INTO SE_ASOCIA VALUES (3024, 3080);
INSERT INTO SE_ASOCIA VALUES (3024, 3081);
INSERT INTO SE_ASOCIA VALUES (3025, 3052);
INSERT INTO SE_ASOCIA VALUES (3025, 3066);
INSERT INTO SE_ASOCIA VALUES (3026, 3005);
INSERT INTO SE_ASOCIA VALUES (3026, 3056);
INSERT INTO SE_ASOCIA VALUES (3026, 3089);
INSERT INTO SE_ASOCIA VALUES (3027, 3048);
INSERT INTO SE_ASOCIA VALUES (3027, 3059);
INSERT INTO SE_ASOCIA VALUES (3027, 3099);
INSERT INTO SE_ASOCIA VALUES (3028, 3080);
INSERT INTO SE_ASOCIA VALUES (3028, 3095);
INSERT INTO SE_ASOCIA VALUES (3029, 3012);
INSERT INTO SE_ASOCIA VALUES (3030, 3014);
INSERT INTO SE_ASOCIA VALUES (3030, 3062);
INSERT INTO SE_ASOCIA VALUES (3030, 3095);
INSERT INTO SE_ASOCIA VALUES (3031, 3075);
INSERT INTO SE_ASOCIA VALUES (3031, 3090);
INSERT INTO SE_ASOCIA VALUES (3032, 3015);
INSERT INTO SE_ASOCIA VALUES (3032, 3050);
INSERT INTO SE_ASOCIA VALUES (3032, 3091);
INSERT INTO SE_ASOCIA VALUES (3032, 3096);
INSERT INTO SE_ASOCIA VALUES (3033, 3036);
INSERT INTO SE_ASOCIA VALUES (3033, 3079);
INSERT INTO SE_ASOCIA VALUES (3033, 3090);
INSERT INTO SE_ASOCIA VALUES (3033, 3100);
INSERT INTO SE_ASOCIA VALUES (3034, 3058);
INSERT INTO SE_ASOCIA VALUES (3035, 3020);
INSERT INTO SE_ASOCIA VALUES (3035, 3029);
INSERT INTO SE_ASOCIA VALUES (3035, 3043);
INSERT INTO SE_ASOCIA VALUES (3036, 3013);
INSERT INTO SE_ASOCIA VALUES (3037, 3051);
INSERT INTO SE_ASOCIA VALUES (3038, 3001);
INSERT INTO SE_ASOCIA VALUES (3038, 3006);
INSERT INTO SE_ASOCIA VALUES (3038, 3016);
INSERT INTO SE_ASOCIA VALUES (3039, 3074);
INSERT INTO SE_ASOCIA VALUES (3039, 3076);
INSERT INTO SE_ASOCIA VALUES (3040, 3011);
INSERT INTO SE_ASOCIA VALUES (3040, 3016);
INSERT INTO SE_ASOCIA VALUES (3040, 3023);
INSERT INTO SE_ASOCIA VALUES (3040, 3091);
INSERT INTO SE_ASOCIA VALUES (3041, 3008);
INSERT INTO SE_ASOCIA VALUES (3041, 3026);
INSERT INTO SE_ASOCIA VALUES (3041, 3062);
INSERT INTO SE_ASOCIA VALUES (3041, 3091);
INSERT INTO SE_ASOCIA VALUES (3042, 3009);
INSERT INTO SE_ASOCIA VALUES (3042, 3073);
INSERT INTO SE_ASOCIA VALUES (3043, 3025);
INSERT INTO SE_ASOCIA VALUES (3044, 3036);
INSERT INTO SE_ASOCIA VALUES (3045, 3040);
INSERT INTO SE_ASOCIA VALUES (3045, 3081);
INSERT INTO SE_ASOCIA VALUES (3046, 3024);
INSERT INTO SE_ASOCIA VALUES (3046, 3033);
INSERT INTO SE_ASOCIA VALUES (3046, 3043);
INSERT INTO SE_ASOCIA VALUES (3047, 3018);
INSERT INTO SE_ASOCIA VALUES (3047, 3054);
INSERT INTO SE_ASOCIA VALUES (3047, 3060);
INSERT INTO SE_ASOCIA VALUES (3048, 3029);
INSERT INTO SE_ASOCIA VALUES (3048, 3074);
INSERT INTO SE_ASOCIA VALUES (3049, 3041);
INSERT INTO SE_ASOCIA VALUES (3049, 3061);
INSERT INTO SE_ASOCIA VALUES (3049, 3070);
INSERT INTO SE_ASOCIA VALUES (3050, 3047);
INSERT INTO SE_ASOCIA VALUES (3050, 3065);
INSERT INTO SE_ASOCIA VALUES (3050, 3078);
INSERT INTO SE_ASOCIA VALUES (3051, 3032);
INSERT INTO SE_ASOCIA VALUES (3051, 3078);
INSERT INTO SE_ASOCIA VALUES (3052, 3069);
INSERT INTO SE_ASOCIA VALUES (3053, 3027);
INSERT INTO SE_ASOCIA VALUES (3053, 3062);
INSERT INTO SE_ASOCIA VALUES (3053, 3097);
  COMMIT;
END;
 

BEGIN
INSERT INTO SE_ASOCIA VALUES (3054, 3021);
INSERT INTO SE_ASOCIA VALUES (3054, 3030);
INSERT INTO SE_ASOCIA VALUES (3055, 3004);
INSERT INTO SE_ASOCIA VALUES (3055, 3010);
INSERT INTO SE_ASOCIA VALUES (3055, 3031);
INSERT INTO SE_ASOCIA VALUES (3056, 3056);
INSERT INTO SE_ASOCIA VALUES (3056, 3072);
INSERT INTO SE_ASOCIA VALUES (3056, 3076);
INSERT INTO SE_ASOCIA VALUES (3056, 3087);
INSERT INTO SE_ASOCIA VALUES (3057, 3068);
INSERT INTO SE_ASOCIA VALUES (3058, 3066);
INSERT INTO SE_ASOCIA VALUES (3058, 3069);
INSERT INTO SE_ASOCIA VALUES (3058, 3098);
INSERT INTO SE_ASOCIA VALUES (3059, 3026);
INSERT INTO SE_ASOCIA VALUES (3059, 3057);
INSERT INTO SE_ASOCIA VALUES (3060, 3002);
INSERT INTO SE_ASOCIA VALUES (3061, 3012);
INSERT INTO SE_ASOCIA VALUES (3061, 3019);
INSERT INTO SE_ASOCIA VALUES (3062, 3069);
INSERT INTO SE_ASOCIA VALUES (3063, 3022);
INSERT INTO SE_ASOCIA VALUES (3063, 3098);
INSERT INTO SE_ASOCIA VALUES (3064, 3003);
INSERT INTO SE_ASOCIA VALUES (3064, 3010);
INSERT INTO SE_ASOCIA VALUES (3064, 3021);
INSERT INTO SE_ASOCIA VALUES (3065, 3028);
INSERT INTO SE_ASOCIA VALUES (3065, 3079);
INSERT INTO SE_ASOCIA VALUES (3066, 3053);
INSERT INTO SE_ASOCIA VALUES (3066, 3088);
INSERT INTO SE_ASOCIA VALUES (3066, 3094);
INSERT INTO SE_ASOCIA VALUES (3067, 3018);
INSERT INTO SE_ASOCIA VALUES (3067, 3029);
INSERT INTO SE_ASOCIA VALUES (3067, 3045);
INSERT INTO SE_ASOCIA VALUES (3068, 3037);
INSERT INTO SE_ASOCIA VALUES (3068, 3055);
INSERT INTO SE_ASOCIA VALUES (3068, 3056);
INSERT INTO SE_ASOCIA VALUES (3068, 3071);
INSERT INTO SE_ASOCIA VALUES (3069, 3011);
INSERT INTO SE_ASOCIA VALUES (3069, 3040);
INSERT INTO SE_ASOCIA VALUES (3069, 3049);
INSERT INTO SE_ASOCIA VALUES (3070, 3038);
INSERT INTO SE_ASOCIA VALUES (3070, 3058);
INSERT INTO SE_ASOCIA VALUES (3070, 3094);
INSERT INTO SE_ASOCIA VALUES (3071, 3008);
INSERT INTO SE_ASOCIA VALUES (3071, 3093);
INSERT INTO SE_ASOCIA VALUES (3072, 3025);
INSERT INTO SE_ASOCIA VALUES (3072, 3081);
INSERT INTO SE_ASOCIA VALUES (3073, 3021);
INSERT INTO SE_ASOCIA VALUES (3073, 3030);
INSERT INTO SE_ASOCIA VALUES (3073, 3032);
INSERT INTO SE_ASOCIA VALUES (3074, 3006);
INSERT INTO SE_ASOCIA VALUES (3074, 3035);
INSERT INTO SE_ASOCIA VALUES (3075, 3043);
INSERT INTO SE_ASOCIA VALUES (3075, 3044);
INSERT INTO SE_ASOCIA VALUES (3075, 3089);
INSERT INTO SE_ASOCIA VALUES (3076, 3007);
INSERT INTO SE_ASOCIA VALUES (3076, 3089);
INSERT INTO SE_ASOCIA VALUES (3077, 3030);
INSERT INTO SE_ASOCIA VALUES (3077, 3058);
INSERT INTO SE_ASOCIA VALUES (3077, 3086);
INSERT INTO SE_ASOCIA VALUES (3077, 3097);
INSERT INTO SE_ASOCIA VALUES (3078, 3038);
INSERT INTO SE_ASOCIA VALUES (3079, 3008);
INSERT INTO SE_ASOCIA VALUES (3079, 3072);
INSERT INTO SE_ASOCIA VALUES (3079, 3077);
INSERT INTO SE_ASOCIA VALUES (3080, 3019);
INSERT INTO SE_ASOCIA VALUES (3080, 3035);
INSERT INTO SE_ASOCIA VALUES (3080, 3092);
INSERT INTO SE_ASOCIA VALUES (3081, 3031);
INSERT INTO SE_ASOCIA VALUES (3081, 3039);
INSERT INTO SE_ASOCIA VALUES (3082, 3013);
INSERT INTO SE_ASOCIA VALUES (3082, 3070);
INSERT INTO SE_ASOCIA VALUES (3083, 3011);
INSERT INTO SE_ASOCIA VALUES (3084, 3034);
INSERT INTO SE_ASOCIA VALUES (3084, 3038);
INSERT INTO SE_ASOCIA VALUES (3084, 3046);
INSERT INTO SE_ASOCIA VALUES (3085, 3070);
INSERT INTO SE_ASOCIA VALUES (3086, 3045);
INSERT INTO SE_ASOCIA VALUES (3086, 3086);
INSERT INTO SE_ASOCIA VALUES (3086, 3092);
INSERT INTO SE_ASOCIA VALUES (3086, 3100);
INSERT INTO SE_ASOCIA VALUES (3087, 3005);
INSERT INTO SE_ASOCIA VALUES (3087, 3049);
INSERT INTO SE_ASOCIA VALUES (3087, 3085);
INSERT INTO SE_ASOCIA VALUES (3088, 3063);
INSERT INTO SE_ASOCIA VALUES (3089, 3082);
INSERT INTO SE_ASOCIA VALUES (3090, 3007);
INSERT INTO SE_ASOCIA VALUES (3090, 3045);
INSERT INTO SE_ASOCIA VALUES (3090, 3085);
INSERT INTO SE_ASOCIA VALUES (3090, 3092);
INSERT INTO SE_ASOCIA VALUES (3091, 3023);
INSERT INTO SE_ASOCIA VALUES (3092, 3041);
INSERT INTO SE_ASOCIA VALUES (3092, 3076);
INSERT INTO SE_ASOCIA VALUES (3092, 3085);
INSERT INTO SE_ASOCIA VALUES (3093, 3065);
INSERT INTO SE_ASOCIA VALUES (3093, 3077);
INSERT INTO SE_ASOCIA VALUES (3094, 3039);
INSERT INTO SE_ASOCIA VALUES (3094, 3098);
INSERT INTO SE_ASOCIA VALUES (3095, 3032);
INSERT INTO SE_ASOCIA VALUES (3096, 3031);
INSERT INTO SE_ASOCIA VALUES (3096, 3037);
INSERT INTO SE_ASOCIA VALUES (3096, 3041);
INSERT INTO SE_ASOCIA VALUES (3097, 3025);
  COMMIT;
END;
 

BEGIN
INSERT INTO SE_ASOCIA VALUES (3097, 3061);
INSERT INTO SE_ASOCIA VALUES (3097, 3094);
INSERT INTO SE_ASOCIA VALUES (3098, 3017);
INSERT INTO SE_ASOCIA VALUES (3098, 3053);
INSERT INTO SE_ASOCIA VALUES (3099, 3026);
INSERT INTO SE_ASOCIA VALUES (3099, 3048);
INSERT INTO SE_ASOCIA VALUES (3099, 3077);
INSERT INTO SE_ASOCIA VALUES (3099, 3087);
INSERT INTO SE_ASOCIA VALUES (3100, 3027);
INSERT INTO SE_ASOCIA VALUES (3100, 3068);
  COMMIT;
END;




--PEDIDO

BEGIN
  INSERT INTO PEDIDO VALUES (7001, TO_DATE('2026-03-23', 'YYYY-MM-DD'), '14:17', 'Entregado', 56.40, 10.00, 66.40, 1639, 1346, 1095);
  INSERT INTO PEDIDO VALUES (7002, TO_DATE('2026-04-25', 'YYYY-MM-DD'), '22:02', 'Entregado', 74.19, 10.00, 84.19, 1588, 1287, 1026);
  INSERT INTO PEDIDO VALUES (7003, TO_DATE('2026-04-02', 'YYYY-MM-DD'), '22:14', 'Entregado', 87.59, 10.00, 97.59, 1664, 1388, 1021);
  INSERT INTO PEDIDO VALUES (7004, TO_DATE('2026-03-31', 'YYYY-MM-DD'), '21:09', 'Entregado', 196.79, 10.00, 206.79, 1398, 1047, 1049);
  INSERT INTO PEDIDO VALUES (7005, TO_DATE('2026-01-13', 'YYYY-MM-DD'), '13:38', 'Entregado', 34.78, 20.00, 54.78, 1575, 1274, 1016);
  INSERT INTO PEDIDO VALUES (7006, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '13:53', 'Entregado', 224.23, 15.00, 239.23, 1596, 1295, 1025);
  INSERT INTO PEDIDO VALUES (7007, TO_DATE('2026-04-01', 'YYYY-MM-DD'), '14:14', 'En camino', 246.67, 12.50, 259.17, 1719, 1443, 1013);
  INSERT INTO PEDIDO VALUES (7008, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '14:53', 'Entregado', 108.29, 12.50, 120.79, 1637, 1343, 1035);
  INSERT INTO PEDIDO VALUES (7009, TO_DATE('2026-03-31', 'YYYY-MM-DD'), '10:38', 'Entregado', 145.18, 12.50, 157.68, 1432, 1083, 1060);
  INSERT INTO PEDIDO VALUES (7010, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '14:44', 'Entregado', 179.04, 10.00, 189.04, 1448, 1117, 1005);
  INSERT INTO PEDIDO VALUES (7011, TO_DATE('2026-04-14', 'YYYY-MM-DD'), '13:04', 'Entregado', 237.15, 15.00, 252.15, 1445, 1108, 1084);
  INSERT INTO PEDIDO VALUES (7012, TO_DATE('2026-03-05', 'YYYY-MM-DD'), '14:29', 'Entregado', 56.42, 15.00, 71.42, 1658, 1382, 1075);
  INSERT INTO PEDIDO VALUES (7013, TO_DATE('2026-02-24', 'YYYY-MM-DD'), '20:23', 'Entregado', 249.45, 20.00, 269.45, 1397, 1046, 1097);
  INSERT INTO PEDIDO VALUES (7014, TO_DATE('2026-01-07', 'YYYY-MM-DD'), '12:40', 'Entregado', 178.11, 10.00, 188.11, 1523, 1197, 1049);
  INSERT INTO PEDIDO VALUES (7015, TO_DATE('2026-03-18', 'YYYY-MM-DD'), '16:35', 'En preparación', 95.73, 12.50, 108.23, 1388, 1037, 1058);
  INSERT INTO PEDIDO VALUES (7016, TO_DATE('2026-03-10', 'YYYY-MM-DD'), '13:28', 'Cancelado', 45.47, 15.00, 60.47, 1528, 1202, 1051);
  INSERT INTO PEDIDO VALUES (7017, TO_DATE('2026-01-20', 'YYYY-MM-DD'), '12:21', 'En preparación', 94.61, 20.00, 114.61, 1581, 1280, 1045);
  INSERT INTO PEDIDO VALUES (7018, TO_DATE('2026-01-14', 'YYYY-MM-DD'), '19:42', 'Entregado', 231.13, 20.00, 251.13, 1524, 1198, 1014);
  INSERT INTO PEDIDO VALUES (7019, TO_DATE('2026-01-26', 'YYYY-MM-DD'), '19:28', 'Entregado', 222.14, 15.00, 237.14, 1404, 1059, 1024);
  INSERT INTO PEDIDO VALUES (7020, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '21:52', 'En camino', 160.77, 10.00, 170.77, 1530, 1204, 1063);
  INSERT INTO PEDIDO VALUES (7021, TO_DATE('2026-01-09', 'YYYY-MM-DD'), '08:44', 'Entregado', 87.27, 20.00, 107.27, 1391, 1040, 1076);
  INSERT INTO PEDIDO VALUES (7022, TO_DATE('2026-01-23', 'YYYY-MM-DD'), '13:41', 'Entregado', 41.74, 12.50, 54.24, 1373, 1022, 1072);
  INSERT INTO PEDIDO VALUES (7023, TO_DATE('2026-02-09', 'YYYY-MM-DD'), '08:08', 'Entregado', 101.44, 20.00, 121.44, 1496, 1170, 1098);
  INSERT INTO PEDIDO VALUES (7024, TO_DATE('2026-04-12', 'YYYY-MM-DD'), '14:48', 'En preparación', 188.75, 12.50, 201.25, 1481, 1155, 1051);
  INSERT INTO PEDIDO VALUES (7025, TO_DATE('2026-01-06', 'YYYY-MM-DD'), '21:05', 'Entregado', 113.88, 10.00, 123.88, 1533, 1209, 1021);
  INSERT INTO PEDIDO VALUES (7026, TO_DATE('2026-03-08', 'YYYY-MM-DD'), '19:42', 'En camino', 234.33, 12.50, 246.83, 1538, 1214, 1007);
  INSERT INTO PEDIDO VALUES (7027, TO_DATE('2026-01-16', 'YYYY-MM-DD'), '21:03', 'En preparación', 106.33, 20.00, 126.33, 1699, 1348, 1032);
  INSERT INTO PEDIDO VALUES (7028, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '12:00', 'En preparación', 87.52, 10.00, 97.52, 1400, 1049, 1046);
  INSERT INTO PEDIDO VALUES (7029, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '19:49', 'Entregado', 170.82, 12.50, 183.32, 1527, 1162, 1004);
  INSERT INTO PEDIDO VALUES (7030, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '13:06', 'Entregado', 222.02, 10.00, 232.02, 1555, 1204, 1043);
  INSERT INTO PEDIDO VALUES (7031, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '13:40', 'Entregado', 133.00, 12.50, 145.50, 1530, 1168, 1038);
  INSERT INTO PEDIDO VALUES (7032, TO_DATE('2026-04-18', 'YYYY-MM-DD'), '12:28', 'Cancelado', 154.51, 15.00, 169.51, 1667, 1316, 1006);
  INSERT INTO PEDIDO VALUES (7033, TO_DATE('2026-04-21', 'YYYY-MM-DD'), '08:52', 'Entregado', 143.78, 12.50, 156.28, 1422, 1071, 1092);
  INSERT INTO PEDIDO VALUES (7034, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '13:51', 'En camino', 211.53, 12.50, 224.03, 1626, 1275, 1001);
  INSERT INTO PEDIDO VALUES (7035, TO_DATE('2026-03-22', 'YYYY-MM-DD'), '13:17', 'Entregado', 201.21, 15.00, 216.21, 1515, 1150, 1024);
  INSERT INTO PEDIDO VALUES (7036, TO_DATE('2026-01-08', 'YYYY-MM-DD'), '21:38', 'Entregado', 90.72, 15.00, 105.72, 1435, 1099, 1073);
  INSERT INTO PEDIDO VALUES (7037, TO_DATE('2026-02-27', 'YYYY-MM-DD'), '13:46', 'Entregado', 222.18, 15.00, 237.18, 1638, 1287, 1006);
  INSERT INTO PEDIDO VALUES (7038, TO_DATE('2026-01-03', 'YYYY-MM-DD'), '13:40', 'Cancelado', 211.75, 12.50, 224.25, 1541, 1179, NULL);
  INSERT INTO PEDIDO VALUES (7039, TO_DATE('2026-01-25', 'YYYY-MM-DD'), '19:25', 'Cancelado', 95.89, 15.00, 110.89, 1374, 1023, 1030);
  INSERT INTO PEDIDO VALUES (7040, TO_DATE('2026-03-08', 'YYYY-MM-DD'), '13:30', 'En preparación', 241.97, 12.50, 254.47, 1599, 1234, 1021);
  INSERT INTO PEDIDO VALUES (7041, TO_DATE('2026-02-14', 'YYYY-MM-DD'), '14:38', 'Entregado', 183.18, 15.00, 198.18, 1461, 1135, 1083);
  INSERT INTO PEDIDO VALUES (7042, TO_DATE('2026-04-10', 'YYYY-MM-DD'), '09:07', 'Entregado', 113.68, 10.00, 123.68, 1381, 1030, 1017);
  INSERT INTO PEDIDO VALUES (7043, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '21:30', 'Entregado', 231.10, 20.00, 251.10, 1404, 1053, 1047);
  INSERT INTO PEDIDO VALUES (7044, TO_DATE('2026-03-31', 'YYYY-MM-DD'), '19:26', 'Entregado', 147.24, 20.00, 167.24, 1696, 1345, 1007);
  INSERT INTO PEDIDO VALUES (7045, TO_DATE('2026-04-19', 'YYYY-MM-DD'), '22:37', 'Cancelado', 106.63, 10.00, 116.63, 1608, 1257, 1056);
  INSERT INTO PEDIDO VALUES (7046, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '20:30', 'Entregado', 233.15, 12.50, 245.65, 1468, 1142, 1030);
  INSERT INTO PEDIDO VALUES (7047, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '19:15', 'En camino', 158.10, 20.00, 178.10, 1555, 1204, 1052);
  INSERT INTO PEDIDO VALUES (7048, TO_DATE('2026-01-24', 'YYYY-MM-DD'), '14:26', 'Entregado', 38.65, 15.00, 53.65, 1600, 1235, 1071);
  INSERT INTO PEDIDO VALUES (7049, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '10:14', 'Entregado', 222.18, 15.00, 237.18, 1550, 1199, 1052);
  INSERT INTO PEDIDO VALUES (7050, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '19:40', 'Cancelado', 142.14, 12.50, 154.64, 1718, 1442, NULL);
  INSERT INTO PEDIDO VALUES (7051, TO_DATE('2026-01-20', 'YYYY-MM-DD'), '13:06', 'Entregado', 241.95, 20.00, 261.95, 1354, 1003, 1052);
  INSERT INTO PEDIDO VALUES (7052, TO_DATE('2026-04-21', 'YYYY-MM-DD'), '22:31', 'Cancelado', 208.97, 10.00, 218.97, 1419, 1068, 1097);
  INSERT INTO PEDIDO VALUES (7053, TO_DATE('2026-04-16', 'YYYY-MM-DD'), '22:15', 'Entregado', 198.81, 12.50, 211.31, 1488, 1162, 1007);
  INSERT INTO PEDIDO VALUES (7054, TO_DATE('2026-01-09', 'YYYY-MM-DD'), '14:14', 'En camino', 225.86, 12.50, 238.36, 1735, 1459, 1032);
  INSERT INTO PEDIDO VALUES (7055, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '19:15', 'Entregado', 104.97, 20.00, 124.97, 1353, 1002, 1050);
  INSERT INTO PEDIDO VALUES (7056, TO_DATE('2026-03-22', 'YYYY-MM-DD'), '21:03', 'En camino', 209.43, 20.00, 229.43, 1445, 1115, 1017);
  INSERT INTO PEDIDO VALUES (7057, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '21:30', 'En preparación', 214.39, 10.00, 224.39, 1475, 1149, 1094);
  INSERT INTO PEDIDO VALUES (7058, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '20:41', 'Cancelado', 133.44, 15.00, 148.44, 1400, 1049, NULL);
  INSERT INTO PEDIDO VALUES (7059, TO_DATE('2026-04-10', 'YYYY-MM-DD'), '21:56', 'Entregado', 69.24, 10.00, 79.24, 1696, 1345, 1003);
  INSERT INTO PEDIDO VALUES (7060, TO_DATE('2026-01-08', 'YYYY-MM-DD'), '12:00', 'Entregado', 234.90, 15.00, 249.90, 1564, 1213, 1026);
  INSERT INTO PEDIDO VALUES (7061, TO_DATE('2026-01-03', 'YYYY-MM-DD'), '22:58', 'Entregado', 183.07, 15.00, 198.07, 1481, 1155, 1012);
  INSERT INTO PEDIDO VALUES (7062, TO_DATE('2026-02-27', 'YYYY-MM-DD'), '13:00', 'En camino', 97.45, 10.00, 107.45, 1404, 1053, 1030);
  INSERT INTO PEDIDO VALUES (7063, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '11:42', 'Entregado', 233.15, 10.00, 243.15, 1550, 1199, 1014);
  INSERT INTO PEDIDO VALUES (7064, TO_DATE('2026-03-31', 'YYYY-MM-DD'), '13:42', 'Entregado', 151.78, 15.00, 166.78, 1381, 1030, 1037);
  INSERT INTO PEDIDO VALUES (7065, TO_DATE('2026-04-19', 'YYYY-MM-DD'), '19:24', 'En camino', 153.25, 20.00, 173.25, 1667, 1316, 1008);
  INSERT INTO PEDIDO VALUES (7066, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '08:48', 'Entregado', 87.21, 15.00, 102.21, 1515, 1150, 1081);
  INSERT INTO PEDIDO VALUES (7067, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '19:40', 'Entregado', 101.44, 12.50, 113.94, 1599, 1234, 1022);
  INSERT INTO PEDIDO VALUES (7068, TO_DATE('2026-04-18', 'YYYY-MM-DD'), '14:38', 'Entregado', 167.33, 12.50, 179.83, 1461, 1135, 1012);
  INSERT INTO PEDIDO VALUES (7069, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '13:21', 'En camino', 43.18, 15.00, 58.18, 1468, 1142, 1045);
  INSERT INTO PEDIDO VALUES (7070, TO_DATE('2026-02-23', 'YYYY-MM-DD'), '13:06', 'Entregado', 246.33, 15.00, 261.33, 1718, 1442, 1028);
  INSERT INTO PEDIDO VALUES (7071, TO_DATE('2026-03-08', 'YYYY-MM-DD'), '19:42', 'Entregado', 183.18, 20.00, 203.18, 1422, 1071, 1008);
  INSERT INTO PEDIDO VALUES (7072, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '10:50', 'En preparación', 241.80, 12.50, 254.30, 1357, 1006, 1079);
  INSERT INTO PEDIDO VALUES (7073, TO_DATE('2026-01-09', 'YYYY-MM-DD'), '21:30', 'Entregado', 147.28, 10.00, 157.28, 1699, 1348, 1012);
  INSERT INTO PEDIDO VALUES (7074, TO_DATE('2026-01-21', 'YYYY-MM-DD'), '12:00', 'Entregado', 222.02, 12.50, 234.52, 1493, 1167, 1032);
  INSERT INTO PEDIDO VALUES (7075, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '19:49', 'Entregado', 41.50, 12.50, 54.00, 1667, 1316, 1021);
  INSERT INTO PEDIDO VALUES (7076, TO_DATE('2026-03-22', 'YYYY-MM-DD'), '21:05', 'Cancelado', 65.55, 10.00, 75.55, 1481, 1155, 1045);
  INSERT INTO PEDIDO VALUES (7077, TO_DATE('2026-01-24', 'YYYY-MM-DD'), '08:48', 'En camino', 225.44, 20.00, 245.44, 1564, 1213, 1012);
  INSERT INTO PEDIDO VALUES (7078, TO_DATE('2026-04-10', 'YYYY-MM-DD'), '21:03', 'En camino', 225.86, 15.00, 240.86, 1400, 1049, 1056);
  INSERT INTO PEDIDO VALUES (7079, TO_DATE('2026-01-08', 'YYYY-MM-DD'), '22:31', 'Cancelado', 188.75, 12.50, 201.25, 1500, 1123, 1060);
  INSERT INTO PEDIDO VALUES (7080, TO_DATE('2026-01-03', 'YYYY-MM-DD'), '13:06', 'Entregado', 219.00, 15.00, 234.00, 1716, 1440, 1066);
  INSERT INTO PEDIDO VALUES (7081, TO_DATE('2026-02-27', 'YYYY-MM-DD'), '14:26', 'Entregado', 113.88, 10.00, 123.88, 1435, 1099, 1032);
  INSERT INTO PEDIDO VALUES (7082, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '19:25', 'Cancelado', 234.33, 15.00, 249.33, 1735, 1459, 1059);
  INSERT INTO PEDIDO VALUES (7083, TO_DATE('2026-03-31', 'YYYY-MM-DD'), '13:40', 'Entregado', 68.32, 20.00, 88.32, 1353, 1002, 1048);
  INSERT INTO PEDIDO VALUES (7084, TO_DATE('2026-04-19', 'YYYY-MM-DD'), '22:15', 'Entregado', 106.33, 12.50, 118.83, 1419, 1068, 1024);
  INSERT INTO PEDIDO VALUES (7085, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '19:49', 'Entregado', 87.52, 12.50, 100.02, 1488, 1162, 1055);
  INSERT INTO PEDIDO VALUES (7086, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '13:51', 'Entregado', 170.82, 10.00, 180.82, 1461, 1135, 1053);
  INSERT INTO PEDIDO VALUES (7087, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '21:03', 'En camino', 133.00, 12.50, 145.50, 1468, 1142, 1066);
  INSERT INTO PEDIDO VALUES (7088, TO_DATE('2026-03-08', 'YYYY-MM-DD'), '22:31', 'Entregado', 154.51, 10.00, 164.51, 1718, 1442, 1098);
  INSERT INTO PEDIDO VALUES (7089, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '13:06', 'Entregado', 143.78, 15.00, 158.78, 1422, 1071, 1002);
  INSERT INTO PEDIDO VALUES (7090, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '14:26', 'Entregado', 211.53, 20.00, 231.53, 1357, 1006, 1028);
  INSERT INTO PEDIDO VALUES (7091, TO_DATE('2026-04-21', 'YYYY-MM-DD'), '19:25', 'En camino', 201.21, 12.50, 213.71, 1667, 1316, 1039);
  INSERT INTO PEDIDO VALUES (7092, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '13:40', 'Cancelado', 90.72, 12.50, 103.22, 1481, 1155, 1008);
  INSERT INTO PEDIDO VALUES (7093, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '22:15', 'En camino', 222.18, 12.50, 234.68, 1564, 1213, 1060);
  INSERT INTO PEDIDO VALUES (7094, TO_DATE('2026-02-09', 'YYYY-MM-DD'), '19:49', 'En camino', 211.75, 10.00, 221.75, 1400, 1049, 1038);
  INSERT INTO PEDIDO VALUES (7095, TO_DATE('2026-02-01', 'YYYY-MM-DD'), '13:51', 'Entregado', 95.89, 15.00, 110.89, 1500, 1123, 1037);
  INSERT INTO PEDIDO VALUES (7096, TO_DATE('2026-02-19', 'YYYY-MM-DD'), '21:03', 'Entregado', 241.97, 12.50, 254.47, 1716, 1440, 1024);
  INSERT INTO PEDIDO VALUES (7097, TO_DATE('2026-02-23', 'YYYY-MM-DD'), '22:31', 'Cancelado', 183.18, 15.00, 198.18, 1435, 1099, 1072);
  INSERT INTO PEDIDO VALUES (7098, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '13:06', 'Entregado', 113.68, 10.00, 123.68, 1735, 1459, 1043);
  INSERT INTO PEDIDO VALUES (7099, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '14:26', 'Entregado', 231.10, 20.00, 251.10, 1353, 1002, 1074);
  INSERT INTO PEDIDO VALUES (7100, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '19:25', 'Cancelado', 147.24, 20.00, 167.24, 1419, 1068, 1001);
  COMMIT;
END;
 


BEGIN
  INSERT INTO PEDIDO VALUES (7101, TO_DATE('2026-04-10', 'YYYY-MM-DD'), '19:05', 'En preparación', 236.34, 10.00, 246.34, 1637, 1343, 1043);
  INSERT INTO PEDIDO VALUES (7102, TO_DATE('2026-01-13', 'YYYY-MM-DD'), '20:01', 'Entregado', 202.47, 15.00, 217.47, 1631, 1331, 1320);
  INSERT INTO PEDIDO VALUES (7103, TO_DATE('2026-03-03', 'YYYY-MM-DD'), '20:05', 'Entregado', 50.74, 10.00, 60.74, 1558, 1257, 1250);
  INSERT INTO PEDIDO VALUES (7104, TO_DATE('2026-04-23', 'YYYY-MM-DD'), '10:42', 'Entregado', 129.83, 10.00, 139.83, 1564, 1263, 1297);
  INSERT INTO PEDIDO VALUES (7105, TO_DATE('2026-01-06', 'YYYY-MM-DD'), '14:04', 'Entregado', 133.23, 15.00, 148.23, 1462, 1136, 1128);
  INSERT INTO PEDIDO VALUES (7106, TO_DATE('2026-03-25', 'YYYY-MM-DD'), '22:56', 'Entregado', 29.34, 10.00, 39.34, 1353, 1002, 1171);
  INSERT INTO PEDIDO VALUES (7107, TO_DATE('2026-01-19', 'YYYY-MM-DD'), '22:10', 'Entregado', 157.19, 12.50, 169.69, 1389, 1038, 1286);
  INSERT INTO PEDIDO VALUES (7108, TO_DATE('2026-01-28', 'YYYY-MM-DD'), '13:49', 'Entregado', 144.18, 15.00, 159.18, 1544, 1232, 1021);
  INSERT INTO PEDIDO VALUES (7109, TO_DATE('2026-02-23', 'YYYY-MM-DD'), '12:11', 'Entregado', 92.56, 12.50, 105.06, 1674, 1398, 1238);
  INSERT INTO PEDIDO VALUES (7110, TO_DATE('2026-01-06', 'YYYY-MM-DD'), '21:31', 'Entregado', 208.70, 20.00, 228.70, 1374, 1023, 1242);
  INSERT INTO PEDIDO VALUES (7111, TO_DATE('2026-04-22', 'YYYY-MM-DD'), '13:28', 'Cancelado', 141.82, 20.00, 161.82, 1477, 1151, NULL);
  INSERT INTO PEDIDO VALUES (7112, TO_DATE('2026-04-10', 'YYYY-MM-DD'), '13:49', 'Entregado', 144.20, 20.00, 164.20, 1518, 1192, 1337);
  INSERT INTO PEDIDO VALUES (7113, TO_DATE('2026-02-02', 'YYYY-MM-DD'), '21:06', 'Cancelado', 207.24, 12.50, 219.74, 1598, 1297, NULL);
  INSERT INTO PEDIDO VALUES (7114, TO_DATE('2026-04-19', 'YYYY-MM-DD'), '18:50', 'En camino', 187.15, 10.00, 197.15, 1528, 1202, 1110);
  INSERT INTO PEDIDO VALUES (7115, TO_DATE('2026-01-07', 'YYYY-MM-DD'), '09:14', 'Entregado', 44.73, 15.00, 59.73, 1482, 1156, 1236);
  INSERT INTO PEDIDO VALUES (7116, TO_DATE('2026-01-09', 'YYYY-MM-DD'), '19:44', 'Entregado', 70.43, 20.00, 90.43, 1440, 1099, 1236);
  INSERT INTO PEDIDO VALUES (7117, TO_DATE('2026-03-06', 'YYYY-MM-DD'), '13:59', 'En preparación', 140.88, 20.00, 160.88, 1435, 1089, 1300);
  INSERT INTO PEDIDO VALUES (7118, TO_DATE('2026-01-27', 'YYYY-MM-DD'), '13:34', 'Entregado', 228.95, 20.00, 248.95, 1496, 1170, 1072);
  INSERT INTO PEDIDO VALUES (7119, TO_DATE('2026-01-17', 'YYYY-MM-DD'), '12:59', 'Entregado', 147.86, 15.00, 162.86, 1434, 1087, 1001);
  INSERT INTO PEDIDO VALUES (7120, TO_DATE('2026-03-27', 'YYYY-MM-DD'), '19:48', 'En camino', 230.99, 10.00, 240.99, 1539, 1221, 1201);
  INSERT INTO PEDIDO VALUES (7121, TO_DATE('2026-04-05', 'YYYY-MM-DD'), '14:24', 'Listo para entregar', 230.92, 15.00, 245.92, 1576, 1275, 1324);
  INSERT INTO PEDIDO VALUES (7122, TO_DATE('2026-04-28', 'YYYY-MM-DD'), '13:43', 'Entregado', 59.07, 10.00, 69.07, 1667, 1391, 1134);
  INSERT INTO PEDIDO VALUES (7123, TO_DATE('2026-02-05', 'YYYY-MM-DD'), '21:33', 'Entregado', 109.45, 12.50, 121.95, 1478, 1152, 1301);
  INSERT INTO PEDIDO VALUES (7124, TO_DATE('2026-02-20', 'YYYY-MM-DD'), '13:14', 'En camino', 62.20, 15.00, 77.20, 1352, 1001, 1038);
  INSERT INTO PEDIDO VALUES (7125, TO_DATE('2026-03-03', 'YYYY-MM-DD'), '13:53', 'Entregado', 132.91, 20.00, 152.91, 1622, 1321, 1245);
  INSERT INTO PEDIDO VALUES (7126, TO_DATE('2026-01-21', 'YYYY-MM-DD'), '13:41', 'Entregado', 71.37, 20.00, 91.37, 1687, 1411, 1343);
  INSERT INTO PEDIDO VALUES (7127, TO_DATE('2026-03-02', 'YYYY-MM-DD'), '22:42', 'En camino', 31.06, 20.00, 51.06, 1384, 1033, 1072);
  INSERT INTO PEDIDO VALUES (7128, TO_DATE('2026-04-24', 'YYYY-MM-DD'), '18:22', 'En camino', 249.03, 15.00, 264.03, 1640, 1348, 1299);
  INSERT INTO PEDIDO VALUES (7129, TO_DATE('2026-02-12', 'YYYY-MM-DD'), '21:36', 'Entregado', 208.21, 15.00, 223.21, 1388, 1037, 1274);
  INSERT INTO PEDIDO VALUES (7130, TO_DATE('2026-03-30', 'YYYY-MM-DD'), '21:32', 'Entregado', 97.24, 15.00, 112.24, 1394, 1043, 1270);
  INSERT INTO PEDIDO VALUES (7131, TO_DATE('2026-03-17', 'YYYY-MM-DD'), '19:52', 'Entregado', 108.67, 10.00, 118.67, 1528, 1202, 1020);
  INSERT INTO PEDIDO VALUES (7132, TO_DATE('2026-03-27', 'YYYY-MM-DD'), '14:42', 'Entregado', 95.43, 15.00, 110.43, 1539, 1222, 1264);
  INSERT INTO PEDIDO VALUES (7133, TO_DATE('2026-04-27', 'YYYY-MM-DD'), '13:16', 'Entregado', 229.64, 12.50, 242.14, 1504, 1178, 1259);
  INSERT INTO PEDIDO VALUES (7134, TO_DATE('2026-01-11', 'YYYY-MM-DD'), '19:43', 'Entregado', 219.08, 12.50, 231.58, 1432, 1083, 1245);
  INSERT INTO PEDIDO VALUES (7135, TO_DATE('2026-03-05', 'YYYY-MM-DD'), '20:56', 'Entregado', 164.47, 12.50, 176.97, 1573, 1272, 1125);
  INSERT INTO PEDIDO VALUES (7136, TO_DATE('2026-03-30', 'YYYY-MM-DD'), '14:48', 'Entregado', 199.03, 15.00, 214.03, 1417, 1066, 1288);
  INSERT INTO PEDIDO VALUES (7137, TO_DATE('2026-03-14', 'YYYY-MM-DD'), '22:02', 'Entregado', 234.19, 20.00, 254.19, 1729, 1453, 1023);
  INSERT INTO PEDIDO VALUES (7138, TO_DATE('2026-03-19', 'YYYY-MM-DD'), '21:14', 'Entregado', 69.59, 20.00, 89.59, 1602, 1301, 1253);
  INSERT INTO PEDIDO VALUES (7139, TO_DATE('2026-01-07', 'YYYY-MM-DD'), '12:53', 'Entregado', 234.09, 12.50, 246.59, 1550, 1248, 1347);
  INSERT INTO PEDIDO VALUES (7140, TO_DATE('2026-04-07', 'YYYY-MM-DD'), '19:55', 'Cancelado', 158.07, 20.00, 178.07, 1435, 1089, NULL);
  INSERT INTO PEDIDO VALUES (7141, TO_DATE('2026-01-28', 'YYYY-MM-DD'), '20:32', 'Listo para entregar', 176.71, 15.00, 191.71, 1632, 1333, 1026);
  INSERT INTO PEDIDO VALUES (7142, TO_DATE('2026-04-27', 'YYYY-MM-DD'), '21:38', 'Cancelado', 89.89, 20.00, 109.89, 1674, 1398, NULL);
  INSERT INTO PEDIDO VALUES (7143, TO_DATE('2026-02-06', 'YYYY-MM-DD'), '13:37', 'Confirmado', 52.11, 10.00, 62.11, 1718, 1442, NULL);
  INSERT INTO PEDIDO VALUES (7144, TO_DATE('2026-01-28', 'YYYY-MM-DD'), '21:34', 'Entregado', 90.91, 15.00, 105.91, 1647, 1364, 1330);
  INSERT INTO PEDIDO VALUES (7145, TO_DATE('2026-01-23', 'YYYY-MM-DD'), '20:56', 'Entregado', 243.85, 20.00, 263.85, 1450, 1122, 1099);
  INSERT INTO PEDIDO VALUES (7146, TO_DATE('2026-02-26', 'YYYY-MM-DD'), '14:11', 'Entregado', 191.90, 20.00, 211.90, 1572, 1271, 1249);
  INSERT INTO PEDIDO VALUES (7147, TO_DATE('2026-04-07', 'YYYY-MM-DD'), '22:52', 'Entregado', 125.19, 15.00, 140.19, 1617, 1316, 1053);
  INSERT INTO PEDIDO VALUES (7148, TO_DATE('2026-04-02', 'YYYY-MM-DD'), '22:53', 'Entregado', 48.87, 20.00, 68.87, 1550, 1249, 1050);
  INSERT INTO PEDIDO VALUES (7149, TO_DATE('2026-03-11', 'YYYY-MM-DD'), '21:15', 'Pendiente', 40.94, 20.00, 60.94, 1747, 1489, NULL);
  INSERT INTO PEDIDO VALUES (7150, TO_DATE('2026-02-07', 'YYYY-MM-DD'), '21:25', 'Entregado', 67.38, 20.00, 87.38, 1638, 1345, 1346);
  INSERT INTO PEDIDO VALUES (7151, TO_DATE('2026-03-01', 'YYYY-MM-DD'), '13:58', 'Entregado', 146.31, 20.00, 166.31, 1394, 1043, 1039);
  INSERT INTO PEDIDO VALUES (7152, TO_DATE('2026-01-26', 'YYYY-MM-DD'), '13:11', 'Entregado', 181.36, 12.50, 193.86, 1461, 1135, 1016);
  INSERT INTO PEDIDO VALUES (7153, TO_DATE('2026-01-21', 'YYYY-MM-DD'), '18:38', 'Entregado', 37.53, 15.00, 52.53, 1537, 1217, 1166);
  INSERT INTO PEDIDO VALUES (7154, TO_DATE('2026-02-13', 'YYYY-MM-DD'), '14:59', 'Entregado', 154.77, 12.50, 167.27, 1518, 1192, 1203);
  INSERT INTO PEDIDO VALUES (7155, TO_DATE('2026-01-02', 'YYYY-MM-DD'), '14:58', 'Entregado', 211.74, 15.00, 226.74, 1740, 1474, 1313);
  INSERT INTO PEDIDO VALUES (7156, TO_DATE('2026-02-01', 'YYYY-MM-DD'), '12:39', 'Entregado', 125.13, 15.00, 140.13, 1568, 1267, 1138);
  INSERT INTO PEDIDO VALUES (7157, TO_DATE('2026-04-14', 'YYYY-MM-DD'), '20:16', 'Entregado', 136.05, 12.50, 148.55, 1702, 1426, 1147);
  INSERT INTO PEDIDO VALUES (7158, TO_DATE('2026-01-21', 'YYYY-MM-DD'), '21:10', 'Entregado', 154.67, 15.00, 169.67, 1622, 1321, 1279);
  INSERT INTO PEDIDO VALUES (7159, TO_DATE('2026-01-27', 'YYYY-MM-DD'), '22:01', 'Entregado', 200.48, 10.00, 210.48, 1387, 1036, 1126);
  INSERT INTO PEDIDO VALUES (7160, TO_DATE('2026-04-16', 'YYYY-MM-DD'), '22:24', 'En camino', 240.25, 15.00, 255.25, 1702, 1426, 1263);
  INSERT INTO PEDIDO VALUES (7161, TO_DATE('2026-02-11', 'YYYY-MM-DD'), '22:51', 'Entregado', 39.45, 10.00, 49.45, 1685, 1409, 1257);
  INSERT INTO PEDIDO VALUES (7162, TO_DATE('2026-01-24', 'YYYY-MM-DD'), '13:27', 'Entregado', 55.81, 15.00, 70.81, 1399, 1048, 1251);
  INSERT INTO PEDIDO VALUES (7163, TO_DATE('2026-03-11', 'YYYY-MM-DD'), '12:17', 'En preparación', 200.53, 20.00, 220.53, 1716, 1440, 1242);
  INSERT INTO PEDIDO VALUES (7164, TO_DATE('2026-02-05', 'YYYY-MM-DD'), '13:04', 'En camino', 76.81, 12.50, 89.31, 1662, 1386, 1035);
  INSERT INTO PEDIDO VALUES (7165, TO_DATE('2026-02-04', 'YYYY-MM-DD'), '16:09', 'Listo para entregar', 246.13, 12.50, 258.63, 1587, 1286, 1268);
  INSERT INTO PEDIDO VALUES (7166, TO_DATE('2026-01-19', 'YYYY-MM-DD'), '18:46', 'Entregado', 117.96, 10.00, 127.96, 1566, 1265, 1178);
  INSERT INTO PEDIDO VALUES (7167, TO_DATE('2026-04-23', 'YYYY-MM-DD'), '12:53', 'Entregado', 28.97, 15.00, 43.97, 1694, 1418, 1226);
  INSERT INTO PEDIDO VALUES (7168, TO_DATE('2026-01-31', 'YYYY-MM-DD'), '19:26', 'Entregado', 119.89, 12.50, 132.39, 1663, 1387, 1301);
  INSERT INTO PEDIDO VALUES (7169, TO_DATE('2026-04-09', 'YYYY-MM-DD'), '22:19', 'Entregado', 28.84, 15.00, 43.84, 1644, 1357, 1291);
  INSERT INTO PEDIDO VALUES (7170, TO_DATE('2026-01-16', 'YYYY-MM-DD'), '22:36', 'En preparación', 80.10, 20.00, 100.10, 1444, 1107, 1022);
  INSERT INTO PEDIDO VALUES (7171, TO_DATE('2026-02-25', 'YYYY-MM-DD'), '13:11', 'En preparación', 162.15, 15.00, 177.15, 1678, 1402, 1088);
  INSERT INTO PEDIDO VALUES (7172, TO_DATE('2026-04-06', 'YYYY-MM-DD'), '19:32', 'Entregado', 53.58, 10.00, 63.58, 1502, 1176, 1261);
  INSERT INTO PEDIDO VALUES (7173, TO_DATE('2026-01-08', 'YYYY-MM-DD'), '08:58', 'Entregado', 238.05, 10.00, 248.05, 1646, 1362, 1148);
  INSERT INTO PEDIDO VALUES (7174, TO_DATE('2026-04-24', 'YYYY-MM-DD'), '14:31', 'Entregado', 225.92, 12.50, 238.42, 1542, 1228, 1235);
  INSERT INTO PEDIDO VALUES (7175, TO_DATE('2026-01-23', 'YYYY-MM-DD'), '13:41', 'Cancelado', 142.50, 10.00, 152.50, 1736, 1466, 1150);
  INSERT INTO PEDIDO VALUES (7176, TO_DATE('2026-03-22', 'YYYY-MM-DD'), '20:44', 'Entregado', 94.15, 20.00, 114.15, 1739, 1471, 1010);
  INSERT INTO PEDIDO VALUES (7177, TO_DATE('2026-02-24', 'YYYY-MM-DD'), '14:21', 'Entregado', 220.62, 10.00, 230.62, 1702, 1426, 1296);
  INSERT INTO PEDIDO VALUES (7178, TO_DATE('2026-04-04', 'YYYY-MM-DD'), '21:33', 'Cancelado', 33.55, 20.00, 53.55, 1745, 1484, NULL);
  INSERT INTO PEDIDO VALUES (7179, TO_DATE('2026-02-21', 'YYYY-MM-DD'), '14:21', 'Entregado', 141.58, 12.50, 154.08, 1633, 1335, 1266);
  INSERT INTO PEDIDO VALUES (7180, TO_DATE('2026-01-13', 'YYYY-MM-DD'), '13:44', 'Entregado', 168.45, 10.00, 178.45, 1629, 1328, 1330);
  INSERT INTO PEDIDO VALUES (7181, TO_DATE('2026-02-12', 'YYYY-MM-DD'), '23:16', 'En camino', 198.29, 10.00, 208.29, 1737, 1467, 1309);
  INSERT INTO PEDIDO VALUES (7182, TO_DATE('2026-02-27', 'YYYY-MM-DD'), '19:22', 'Entregado', 162.29, 10.00, 172.29, 1688, 1412, 1341);
  INSERT INTO PEDIDO VALUES (7183, TO_DATE('2026-02-27', 'YYYY-MM-DD'), '20:58', 'Entregado', 85.04, 20.00, 105.04, 1484, 1158, 1297);
  INSERT INTO PEDIDO VALUES (7184, TO_DATE('2026-03-21', 'YYYY-MM-DD'), '14:41', 'Entregado', 147.07, 12.50, 159.57, 1395, 1044, 1266);
  INSERT INTO PEDIDO VALUES (7185, TO_DATE('2026-04-09', 'YYYY-MM-DD'), '12:49', 'Entregado', 40.37, 10.00, 50.37, 1707, 1431, 1153);
  INSERT INTO PEDIDO VALUES (7186, TO_DATE('2026-03-13', 'YYYY-MM-DD'), '22:39', 'En camino', 112.95, 10.00, 122.95, 1446, 1111, 1041);
  INSERT INTO PEDIDO VALUES (7187, TO_DATE('2026-02-14', 'YYYY-MM-DD'), '21:24', 'Entregado', 46.38, 12.50, 58.88, 1419, 1068, 1231);
  INSERT INTO PEDIDO VALUES (7188, TO_DATE('2026-02-15', 'YYYY-MM-DD'), '20:06', 'Entregado', 152.95, 10.00, 162.95, 1617, 1316, 1174);
  INSERT INTO PEDIDO VALUES (7189, TO_DATE('2026-03-13', 'YYYY-MM-DD'), '19:32', 'En camino', 193.97, 15.00, 208.97, 1705, 1429, 1010);
  INSERT INTO PEDIDO VALUES (7190, TO_DATE('2026-02-23', 'YYYY-MM-DD'), '14:34', 'Entregado', 218.25, 12.50, 230.75, 1646, 1362, 1217);
  INSERT INTO PEDIDO VALUES (7191, TO_DATE('2026-01-22', 'YYYY-MM-DD'), '22:41', 'Entregado', 137.70, 20.00, 157.70, 1648, 1366, 1295);
  INSERT INTO PEDIDO VALUES (7192, TO_DATE('2026-02-19', 'YYYY-MM-DD'), '13:16', 'Entregado', 54.57, 15.00, 69.57, 1616, 1315, 1160);
  INSERT INTO PEDIDO VALUES (7193, TO_DATE('2026-02-01', 'YYYY-MM-DD'), '12:38', 'Entregado', 241.99, 20.00, 261.99, 1380, 1029, 1134);
  INSERT INTO PEDIDO VALUES (7194, TO_DATE('2026-02-23', 'YYYY-MM-DD'), '12:58', 'Entregado', 202.31, 10.00, 212.31, 1560, 1259, 1020);
  INSERT INTO PEDIDO VALUES (7195, TO_DATE('2026-01-26', 'YYYY-MM-DD'), '20:30', 'En camino', 244.09, 15.00, 259.09, 1487, 1161, 1288);
  INSERT INTO PEDIDO VALUES (7196, TO_DATE('2026-04-27', 'YYYY-MM-DD'), '13:59', 'Listo para entregar', 171.14, 10.00, 181.14, 1747, 1490, 1310);
  INSERT INTO PEDIDO VALUES (7197, TO_DATE('2026-03-22', 'YYYY-MM-DD'), '21:12', 'En camino', 242.80, 10.00, 252.80, 1531, 1206, 1319);
  INSERT INTO PEDIDO VALUES (7198, TO_DATE('2026-02-16', 'YYYY-MM-DD'), '13:24', 'En camino', 116.93, 15.00, 131.93, 1457, 1131, 1312);
  INSERT INTO PEDIDO VALUES (7199, TO_DATE('2026-01-22', 'YYYY-MM-DD'), '21:12', 'Entregado', 235.72, 12.50, 248.22, 1382, 1031, 1194);
  INSERT INTO PEDIDO VALUES (7200, TO_DATE('2026-03-14', 'YYYY-MM-DD'), '20:15', 'Entregado', 233.18, 20.00, 253.18, 1741, 1476, 1312);
  COMMIT;
END;


BEGIN
  INSERT INTO PEDIDO VALUES (7201, TO_DATE('2026-04-12', 'YYYY-MM-DD'), '20:55', 'Entregado', 91.13, 12.50, 103.63, 1650, 1372, 1136);
  INSERT INTO PEDIDO VALUES (7202, TO_DATE('2026-03-11', 'YYYY-MM-DD'), '12:48', 'Listo para entregar', 170.63, 12.50, 183.13, 1609, 1308, 1139);
  INSERT INTO PEDIDO VALUES (7203, TO_DATE('2026-02-13', 'YYYY-MM-DD'), '21:45', 'Entregado', 213.03, 15.00, 228.03, 1399, 1048, 1014);
  INSERT INTO PEDIDO VALUES (7204, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '13:48', 'Entregado', 150.12, 15.00, 165.12, 1379, 1028, 1006);
  INSERT INTO PEDIDO VALUES (7205, TO_DATE('2026-04-11', 'YYYY-MM-DD'), '20:34', 'Entregado', 217.52, 12.50, 230.02, 1445, 1109, 1046);
  INSERT INTO PEDIDO VALUES (7206, TO_DATE('2026-02-24', 'YYYY-MM-DD'), '20:20', 'Listo para entregar', 73.22, 10.00, 83.22, 1405, 1054, 1121);
  INSERT INTO PEDIDO VALUES (7207, TO_DATE('2026-01-01', 'YYYY-MM-DD'), '19:21', 'Entregado', 137.77, 20.00, 157.77, 1498, 1172, 1012);
  INSERT INTO PEDIDO VALUES (7208, TO_DATE('2026-03-19', 'YYYY-MM-DD'), '21:02', 'Entregado', 237.22, 12.50, 249.72, 1531, 1206, 1187);
  INSERT INTO PEDIDO VALUES (7209, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '13:01', 'Entregado', 224.80, 12.50, 237.30, 1417, 1066, 1131);
  INSERT INTO PEDIDO VALUES (7210, TO_DATE('2026-01-10', 'YYYY-MM-DD'), '13:51', 'Entregado', 237.97, 20.00, 257.97, 1543, 1229, 1197);
  INSERT INTO PEDIDO VALUES (7211, TO_DATE('2026-04-27', 'YYYY-MM-DD'), '12:27', 'Cancelado', 50.83, 15.00, 65.83, 1432, 1082, NULL);
  INSERT INTO PEDIDO VALUES (7212, TO_DATE('2026-01-18', 'YYYY-MM-DD'), '21:53', 'En camino', 142.31, 12.50, 154.81, 1537, 1218, 1022);
  INSERT INTO PEDIDO VALUES (7213, TO_DATE('2026-02-04', 'YYYY-MM-DD'), '22:58', 'Entregado', 206.30, 15.00, 221.30, 1638, 1344, 1210);
  INSERT INTO PEDIDO VALUES (7214, TO_DATE('2026-02-01', 'YYYY-MM-DD'), '13:20', 'Cancelado', 89.64, 12.50, 102.14, 1596, 1295, NULL);
  INSERT INTO PEDIDO VALUES (7215, TO_DATE('2026-02-24', 'YYYY-MM-DD'), '14:47', 'En preparación', 177.84, 20.00, 197.84, 1718, 1442, 1180);
  INSERT INTO PEDIDO VALUES (7216, TO_DATE('2026-01-08', 'YYYY-MM-DD'), '13:12', 'En camino', 168.24, 12.50, 180.74, 1625, 1324, 1199);
  INSERT INTO PEDIDO VALUES (7217, TO_DATE('2026-02-21', 'YYYY-MM-DD'), '14:41', 'Entregado', 108.98, 15.00, 123.98, 1571, 1270, 1243);
  INSERT INTO PEDIDO VALUES (7218, TO_DATE('2026-01-19', 'YYYY-MM-DD'), '15:04', 'En camino', 81.53, 12.50, 94.03, 1447, 1114, 1192);
  INSERT INTO PEDIDO VALUES (7219, TO_DATE('2026-01-04', 'YYYY-MM-DD'), '12:50', 'Entregado', 233.59, 10.00, 243.59, 1650, 1373, 1272);
  INSERT INTO PEDIDO VALUES (7220, TO_DATE('2026-01-09', 'YYYY-MM-DD'), '13:20', 'Entregado', 28.81, 15.00, 43.81, 1386, 1035, 1129);
  INSERT INTO PEDIDO VALUES (7221, TO_DATE('2026-02-07', 'YYYY-MM-DD'), '21:52', 'Entregado', 142.99, 12.50, 155.49, 1579, 1278, 1111);
  INSERT INTO PEDIDO VALUES (7222, TO_DATE('2026-03-23', 'YYYY-MM-DD'), '22:16', 'Entregado', 238.95, 10.00, 248.95, 1609, 1308, 1259);
  INSERT INTO PEDIDO VALUES (7223, TO_DATE('2026-02-06', 'YYYY-MM-DD'), '11:29', 'Entregado', 197.49, 20.00, 217.49, 1500, 1174, 1040);
  INSERT INTO PEDIDO VALUES (7224, TO_DATE('2026-03-11', 'YYYY-MM-DD'), '13:56', 'En preparación', 169.47, 20.00, 189.47, 1376, 1025, 1263);
  INSERT INTO PEDIDO VALUES (7225, TO_DATE('2026-03-10', 'YYYY-MM-DD'), '21:31', 'Entregado', 191.39, 15.00, 206.39, 1548, 1242, 1274);
  INSERT INTO PEDIDO VALUES (7226, TO_DATE('2026-01-13', 'YYYY-MM-DD'), '14:06', 'Entregado', 113.38, 15.00, 128.38, 1631, 1331, 1133);
  INSERT INTO PEDIDO VALUES (7227, TO_DATE('2026-01-18', 'YYYY-MM-DD'), '14:10', 'En preparación', 117.15, 10.00, 127.15, 1659, 1383, 1268);
  INSERT INTO PEDIDO VALUES (7228, TO_DATE('2026-04-08', 'YYYY-MM-DD'), '19:32', 'En preparación', 170.66, 15.00, 185.66, 1600, 1299, 1227);
  INSERT INTO PEDIDO VALUES (7229, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '22:55', 'Entregado', 41.78, 20.00, 61.78, 1587, 1286, 1066);
  INSERT INTO PEDIDO VALUES (7230, TO_DATE('2026-01-10', 'YYYY-MM-DD'), '14:28', 'Entregado', 248.76, 10.00, 258.76, 1394, 1043, 1151);
  INSERT INTO PEDIDO VALUES (7231, TO_DATE('2026-04-14', 'YYYY-MM-DD'), '22:12', 'Entregado', 75.37, 15.00, 90.37, 1470, 1144, 1227);
  INSERT INTO PEDIDO VALUES (7232, TO_DATE('2026-02-10', 'YYYY-MM-DD'), '22:32', 'Entregado', 200.97, 20.00, 220.97, 1727, 1451, 1204);
  INSERT INTO PEDIDO VALUES (7233, TO_DATE('2026-03-16', 'YYYY-MM-DD'), '21:20', 'Entregado', 221.54, 10.00, 231.54, 1501, 1175, 1088);
  INSERT INTO PEDIDO VALUES (7234, TO_DATE('2026-04-07', 'YYYY-MM-DD'), '22:33', 'Entregado', 162.62, 12.50, 175.12, 1540, 1223, 1029);
  INSERT INTO PEDIDO VALUES (7235, TO_DATE('2026-01-22', 'YYYY-MM-DD'), '21:47', 'Entregado', 126.06, 15.00, 141.06, 1641, 1350, 1242);
  INSERT INTO PEDIDO VALUES (7236, TO_DATE('2026-03-13', 'YYYY-MM-DD'), '14:29', 'Listo para entregar', 76.07, 15.00, 91.07, 1441, 1101, 1239);
  INSERT INTO PEDIDO VALUES (7237, TO_DATE('2026-02-22', 'YYYY-MM-DD'), '19:55', 'Entregado', 105.26, 12.50, 117.76, 1543, 1229, 1252);
  INSERT INTO PEDIDO VALUES (7238, TO_DATE('2026-03-15', 'YYYY-MM-DD'), '13:31', 'Listo para entregar', 146.87, 20.00, 166.87, 1472, 1146, 1289);
  INSERT INTO PEDIDO VALUES (7239, TO_DATE('2026-03-03', 'YYYY-MM-DD'), '14:45', 'Entregado', 229.15, 15.00, 244.15, 1527, 1201, 1309);
  INSERT INTO PEDIDO VALUES (7240, TO_DATE('2026-04-26', 'YYYY-MM-DD'), '21:59', 'Entregado', 52.67, 20.00, 72.67, 1462, 1136, 1200);
  INSERT INTO PEDIDO VALUES (7241, TO_DATE('2026-03-08', 'YYYY-MM-DD'), '19:54', 'Entregado', 91.45, 10.00, 101.45, 1540, 1224, 1068);
  INSERT INTO PEDIDO VALUES (7242, TO_DATE('2026-04-23', 'YYYY-MM-DD'), '20:50', 'Pendiente', 233.94, 12.50, 246.44, 1539, 1221, NULL);
  INSERT INTO PEDIDO VALUES (7243, TO_DATE('2026-03-04', 'YYYY-MM-DD'), '21:44', 'Entregado', 99.48, 20.00, 119.48, 1595, 1294, 1011);
  INSERT INTO PEDIDO VALUES (7244, TO_DATE('2026-02-02', 'YYYY-MM-DD'), '12:50', 'Entregado', 50.01, 10.00, 60.01, 1380, 1029, 1197);
  INSERT INTO PEDIDO VALUES (7245, TO_DATE('2026-01-04', 'YYYY-MM-DD'), '13:50', 'Entregado', 44.13, 15.00, 59.13, 1516, 1190, 1035);
  INSERT INTO PEDIDO VALUES (7246, TO_DATE('2026-03-07', 'YYYY-MM-DD'), '14:09', 'En camino', 153.63, 15.00, 168.63, 1443, 1104, 1264);
  INSERT INTO PEDIDO VALUES (7247, TO_DATE('2026-03-02', 'YYYY-MM-DD'), '20:59', 'Entregado', 223.36, 12.50, 235.86, 1477, 1151, 1258);
  INSERT INTO PEDIDO VALUES (7248, TO_DATE('2026-04-04', 'YYYY-MM-DD'), '14:10', 'Cancelado', 204.39, 10.00, 214.39, 1715, 1439, NULL);
  INSERT INTO PEDIDO VALUES (7249, TO_DATE('2026-03-15', 'YYYY-MM-DD'), '20:52', 'Entregado', 76.02, 10.00, 86.02, 1746, 1486, 1120);
  INSERT INTO PEDIDO VALUES (7250, TO_DATE('2026-03-13', 'YYYY-MM-DD'), '14:13', 'En camino', 97.20, 12.50, 109.70, 1642, 1353, 1047);
  INSERT INTO PEDIDO VALUES (7251, TO_DATE('2026-01-24', 'YYYY-MM-DD'), '13:44', 'Entregado', 155.17, 20.00, 175.17, 1731, 1455, 1029);
  INSERT INTO PEDIDO VALUES (7252, TO_DATE('2026-02-19', 'YYYY-MM-DD'), '13:47', 'Entregado', 48.01, 12.50, 60.51, 1549, 1245, 1315);
  INSERT INTO PEDIDO VALUES (7253, TO_DATE('2026-01-16', 'YYYY-MM-DD'), '14:53', 'Entregado', 240.15, 20.00, 260.15, 1363, 1012, 1283);
  INSERT INTO PEDIDO VALUES (7254, TO_DATE('2026-02-04', 'YYYY-MM-DD'), '12:07', 'Entregado', 111.74, 15.00, 126.74, 1389, 1038, 1280);
  INSERT INTO PEDIDO VALUES (7255, TO_DATE('2026-04-15', 'YYYY-MM-DD'), '12:41', 'Entregado', 242.64, 12.50, 255.14, 1731, 1455, 1227);
  INSERT INTO PEDIDO VALUES (7256, TO_DATE('2026-02-09', 'YYYY-MM-DD'), '19:47', 'Entregado', 179.76, 10.00, 189.76, 1377, 1026, 1350);
  INSERT INTO PEDIDO VALUES (7257, TO_DATE('2026-04-24', 'YYYY-MM-DD'), '12:20', 'En preparación', 244.79, 12.50, 257.29, 1480, 1154, 1317);
  INSERT INTO PEDIDO VALUES (7258, TO_DATE('2026-04-03', 'YYYY-MM-DD'), '13:12', 'En camino', 152.39, 15.00, 167.39, 1363, 1012, 1106);
  INSERT INTO PEDIDO VALUES (7259, TO_DATE('2026-03-02', 'YYYY-MM-DD'), '22:17', 'Listo para entregar', 173.97, 15.00, 188.97, 1734, 1462, 1335);
  INSERT INTO PEDIDO VALUES (7260, TO_DATE('2026-03-03', 'YYYY-MM-DD'), '20:09', 'Entregado', 123.21, 20.00, 143.21, 1626, 1325, 1166);
  INSERT INTO PEDIDO VALUES (7261, TO_DATE('2026-01-07', 'YYYY-MM-DD'), '12:44', 'En preparación', 140.37, 15.00, 155.37, 1616, 1315, 1207);
  INSERT INTO PEDIDO VALUES (7262, TO_DATE('2026-01-28', 'YYYY-MM-DD'), '20:12', 'Entregado', 132.79, 10.00, 142.79, 1438, 1094, 1074);
  INSERT INTO PEDIDO VALUES (7263, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '20:47', 'Entregado', 173.95, 10.00, 183.95, 1618, 1317, 1170);
  INSERT INTO PEDIDO VALUES (7264, TO_DATE('2026-03-10', 'YYYY-MM-DD'), '14:00', 'Entregado', 190.19, 15.00, 205.19, 1687, 1411, 1133);
  INSERT INTO PEDIDO VALUES (7265, TO_DATE('2026-04-05', 'YYYY-MM-DD'), '13:46', 'Entregado', 163.82, 12.50, 176.32, 1740, 1473, 1082);
  INSERT INTO PEDIDO VALUES (7266, TO_DATE('2026-02-07', 'YYYY-MM-DD'), '13:21', 'Listo para entregar', 148.31, 15.00, 163.31, 1405, 1054, 1038);
  INSERT INTO PEDIDO VALUES (7267, TO_DATE('2026-02-24', 'YYYY-MM-DD'), '12:18', 'Entregado', 25.84, 20.00, 45.84, 1735, 1463, 1189);
  INSERT INTO PEDIDO VALUES (7268, TO_DATE('2026-03-03', 'YYYY-MM-DD'), '13:00', 'Entregado', 60.31, 20.00, 80.31, 1460, 1134, 1160);
  INSERT INTO PEDIDO VALUES (7269, TO_DATE('2026-03-02', 'YYYY-MM-DD'), '22:12', 'En camino', 73.06, 20.00, 93.06, 1365, 1014, 1103);
  INSERT INTO PEDIDO VALUES (7270, TO_DATE('2026-02-15', 'YYYY-MM-DD'), '17:24', 'En camino', 156.41, 12.50, 168.91, 1591, 1290, 1041);
  INSERT INTO PEDIDO VALUES (7271, TO_DATE('2026-01-26', 'YYYY-MM-DD'), '13:41', 'Entregado', 208.37, 12.50, 220.87, 1424, 1073, 1161);
  INSERT INTO PEDIDO VALUES (7272, TO_DATE('2026-01-24', 'YYYY-MM-DD'), '21:25', 'En camino', 112.29, 15.00, 127.29, 1692, 1416, 1013);
  INSERT INTO PEDIDO VALUES (7273, TO_DATE('2026-03-13', 'YYYY-MM-DD'), '22:42', 'Entregado', 176.91, 10.00, 186.91, 1650, 1374, 1154);
  INSERT INTO PEDIDO VALUES (7274, TO_DATE('2026-03-22', 'YYYY-MM-DD'), '21:07', 'Confirmado', 61.16, 15.00, 76.16, 1504, 1178, NULL);
  INSERT INTO PEDIDO VALUES (7275, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '14:41', 'Listo para entregar', 95.92, 10.00, 105.92, 1519, 1193, 1335);
  INSERT INTO PEDIDO VALUES (7276, TO_DATE('2026-03-28', 'YYYY-MM-DD'), '13:11', 'Entregado', 129.40, 15.00, 144.40, 1688, 1412, 1204);
  INSERT INTO PEDIDO VALUES (7277, TO_DATE('2026-03-14', 'YYYY-MM-DD'), '22:31', 'Listo para entregar', 225.68, 12.50, 238.18, 1681, 1405, 1059);
  INSERT INTO PEDIDO VALUES (7278, TO_DATE('2026-04-09', 'YYYY-MM-DD'), '12:48', 'Cancelado', 54.56, 15.00, 69.56, 1637, 1342, NULL);
  INSERT INTO PEDIDO VALUES (7279, TO_DATE('2026-02-03', 'YYYY-MM-DD'), '09:40', 'Entregado', 142.43, 15.00, 157.43, 1612, 1311, 1024);
  INSERT INTO PEDIDO VALUES (7280, TO_DATE('2026-02-03', 'YYYY-MM-DD'), '21:16', 'Entregado', 152.92, 10.00, 162.92, 1380, 1029, 1130);
  INSERT INTO PEDIDO VALUES (7281, TO_DATE('2026-03-20', 'YYYY-MM-DD'), '22:56', 'Entregado', 25.71, 10.00, 35.71, 1706, 1430, 1171);
  INSERT INTO PEDIDO VALUES (7282, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '13:25', 'Entregado', 148.96, 12.50, 161.46, 1742, 1477, 1296);
  INSERT INTO PEDIDO VALUES (7283, TO_DATE('2026-03-13', 'YYYY-MM-DD'), '16:30', 'Entregado', 68.16, 15.00, 83.16, 1371, 1020, 1105);
  INSERT INTO PEDIDO VALUES (7284, TO_DATE('2026-02-15', 'YYYY-MM-DD'), '19:59', 'En camino', 27.63, 15.00, 42.63, 1668, 1392, 1159);
  INSERT INTO PEDIDO VALUES (7285, TO_DATE('2026-04-02', 'YYYY-MM-DD'), '09:22', 'Entregado', 170.93, 20.00, 190.93, 1492, 1166, 1279);
  INSERT INTO PEDIDO VALUES (7286, TO_DATE('2026-04-16', 'YYYY-MM-DD'), '14:35', 'Entregado', 134.55, 20.00, 154.55, 1656, 1380, 1079);
  INSERT INTO PEDIDO VALUES (7287, TO_DATE('2026-02-19', 'YYYY-MM-DD'), '21:02', 'Entregado', 26.20, 15.00, 41.20, 1683, 1407, 1296);
  INSERT INTO PEDIDO VALUES (7288, TO_DATE('2026-03-18', 'YYYY-MM-DD'), '19:17', 'Entregado', 208.47, 12.50, 220.97, 1396, 1045, 1252);
  INSERT INTO PEDIDO VALUES (7289, TO_DATE('2026-03-07', 'YYYY-MM-DD'), '14:01', 'En preparación', 168.96, 15.00, 183.96, 1609, 1308, 1207);
  INSERT INTO PEDIDO VALUES (7290, TO_DATE('2026-02-05', 'YYYY-MM-DD'), '14:35', 'Entregado', 246.42, 12.50, 258.92, 1579, 1278, 1296);
  INSERT INTO PEDIDO VALUES (7291, TO_DATE('2026-03-10', 'YYYY-MM-DD'), '14:32', 'Entregado', 203.46, 10.00, 213.46, 1749, 1496, 1187);
  INSERT INTO PEDIDO VALUES (7292, TO_DATE('2026-01-02', 'YYYY-MM-DD'), '19:52', 'Pendiente', 193.02, 12.50, 205.52, 1670, 1394, NULL);
  INSERT INTO PEDIDO VALUES (7293, TO_DATE('2026-02-15', 'YYYY-MM-DD'), '14:04', 'Entregado', 66.24, 15.00, 81.24, 1582, 1281, 1145);
  INSERT INTO PEDIDO VALUES (7294, TO_DATE('2026-01-12', 'YYYY-MM-DD'), '21:49', 'En camino', 224.14, 12.50, 236.64, 1399, 1048, 1186);
  INSERT INTO PEDIDO VALUES (7295, TO_DATE('2026-01-26', 'YYYY-MM-DD'), '19:41', 'Entregado', 76.87, 10.00, 86.87, 1442, 1102, 1320);
  INSERT INTO PEDIDO VALUES (7296, TO_DATE('2026-02-09', 'YYYY-MM-DD'), '12:55', 'Entregado', 26.84, 15.00, 41.84, 1466, 1140, 1211);
  INSERT INTO PEDIDO VALUES (7297, TO_DATE('2026-03-22', 'YYYY-MM-DD'), '13:12', 'Entregado', 187.58, 15.00, 202.58, 1671, 1395, 1220);
  INSERT INTO PEDIDO VALUES (7298, TO_DATE('2026-01-26', 'YYYY-MM-DD'), '21:09', 'Entregado', 247.96, 10.00, 257.96, 1747, 1489, 1067);
  INSERT INTO PEDIDO VALUES (7299, TO_DATE('2026-01-29', 'YYYY-MM-DD'), '12:49', 'En preparación', 108.30, 20.00, 128.30, 1515, 1189, 1152);
  INSERT INTO PEDIDO VALUES (7300, TO_DATE('2026-03-15', 'YYYY-MM-DD'), '22:45', 'Entregado', 99.13, 10.00, 109.13, 1629, 1328, 1018);
  COMMIT;
END;

BEGIN
  INSERT INTO PEDIDO VALUES (7301, TO_DATE('2026-04-14', 'YYYY-MM-DD'), '14:26', 'Entregado', 135.53, 10.00, 145.53, 1712, 1436, 1024);
  INSERT INTO PEDIDO VALUES (7302, TO_DATE('2026-01-24', 'YYYY-MM-DD'), '19:22', 'En preparación', 248.88, 10.00, 258.88, 1551, 1250, 1243);
  INSERT INTO PEDIDO VALUES (7303, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '13:30', 'Entregado', 198.81, 15.00, 213.81, 1380, 1029, 1030);
  INSERT INTO PEDIDO VALUES (7304, TO_DATE('2026-04-06', 'YYYY-MM-DD'), '21:05', 'Cancelado', 56.44, 20.00, 76.44, 1555, 1204, 1134);
  INSERT INTO PEDIDO VALUES (7305, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '19:54', 'En camino', 121.75, 12.50, 134.25, 1528, 1202, 1144);
  INSERT INTO PEDIDO VALUES (7306, TO_DATE('2026-02-23', 'YYYY-MM-DD'), '21:38', 'Entregado', 231.10, 10.00, 241.10, 1422, 1071, 1218);
  INSERT INTO PEDIDO VALUES (7307, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '13:06', 'Cancelado', 113.88, 15.00, 128.88, 1353, 1002, 1150);
  INSERT INTO PEDIDO VALUES (7308, TO_DATE('2026-01-21', 'YYYY-MM-DD'), '08:48', 'Entregado', 201.21, 20.00, 221.21, 1461, 1135, 1021);
  INSERT INTO PEDIDO VALUES (7309, TO_DATE('2026-01-09', 'YYYY-MM-DD'), '21:30', 'En preparación', 241.97, 10.00, 251.97, 1500, 1123, 1109);
  INSERT INTO PEDIDO VALUES (7310, TO_DATE('2026-03-31', 'YYYY-MM-DD'), '22:15', 'Entregado', 68.32, 12.50, 80.82, 1604, 1253, 1172);
  INSERT INTO PEDIDO VALUES (7311, TO_DATE('2026-03-08', 'YYYY-MM-DD'), '19:42', 'Entregado', 222.02, 15.00, 237.02, 1374, 1023, 1007);
  INSERT INTO PEDIDO VALUES (7312, TO_DATE('2026-04-18', 'YYYY-MM-DD'), '13:51', 'Entregado', 241.80, 15.00, 256.80, 1716, 1440, 1121);
  INSERT INTO PEDIDO VALUES (7313, TO_DATE('2026-02-12', 'YYYY-MM-DD'), '14:38', 'Entregado', 183.18, 10.00, 193.18, 1541, 1179, 1241);
  INSERT INTO PEDIDO VALUES (7314, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '19:25', 'Cancelado', 209.43, 12.50, 221.93, 1667, 1316, NULL);
  INSERT INTO PEDIDO VALUES (7315, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '14:14', 'Entregado', 104.97, 20.00, 124.97, 1435, 1099, 1317);
  INSERT INTO PEDIDO VALUES (7316, TO_DATE('2026-02-27', 'YYYY-MM-DD'), '22:31', 'Cancelado', 158.10, 15.00, 173.10, 1564, 1213, 1056);
  INSERT INTO PEDIDO VALUES (7317, TO_DATE('2026-01-03', 'YYYY-MM-DD'), '13:40', 'Entregado', 233.15, 12.50, 245.65, 1481, 1155, 1342);
  INSERT INTO PEDIDO VALUES (7318, TO_DATE('2026-01-08', 'YYYY-MM-DD'), '12:00', 'Entregado', 106.63, 10.00, 116.63, 1468, 1142, 1092);
  INSERT INTO PEDIDO VALUES (7319, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '21:03', 'Entregado', 225.44, 20.00, 245.44, 1357, 1006, 1240);
  INSERT INTO PEDIDO VALUES (7320, TO_DATE('2026-04-19', 'YYYY-MM-DD'), '19:15', 'En camino', 142.14, 12.50, 154.64, 1696, 1345, 1202);
  INSERT INTO PEDIDO VALUES (7321, TO_DATE('2026-03-03', 'YYYY-MM-DD'), '13:06', 'Entregado', 188.75, 15.00, 203.75, 1638, 1287, 1150);
  INSERT INTO PEDIDO VALUES (7322, TO_DATE('2026-01-20', 'YYYY-MM-DD'), '09:07', 'Entregado', 167.33, 10.00, 177.33, 1681, 1330, 1361);
  INSERT INTO PEDIDO VALUES (7323, TO_DATE('2026-02-14', 'YYYY-MM-DD'), '22:58', 'Entregado', 170.82, 12.50, 183.32, 1530, 1168, 1108);
  INSERT INTO PEDIDO VALUES (7324, TO_DATE('2026-01-25', 'YYYY-MM-DD'), '19:40', 'Cancelado', 87.52, 12.50, 100.02, 1445, 1115, 1021);
  INSERT INTO PEDIDO VALUES (7325, TO_DATE('2026-04-10', 'YYYY-MM-DD'), '13:30', 'Entregado', 147.24, 20.00, 167.24, 1419, 1068, 1243);
  INSERT INTO PEDIDO VALUES (7326, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '19:49', 'En camino', 147.28, 15.00, 162.28, 1629, 1278, 1056);
  INSERT INTO PEDIDO VALUES (7327, TO_DATE('2026-04-21', 'YYYY-MM-DD'), '21:38', 'Cancelado', 214.39, 12.50, 226.89, 1538, 1176, 1259);
  INSERT INTO PEDIDO VALUES (7328, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '14:26', 'Entregado', 69.24, 10.00, 79.24, 1361, 1010, 1134);
  INSERT INTO PEDIDO VALUES (7329, TO_DATE('2026-02-09', 'YYYY-MM-DD'), '13:06', 'Entregado', 234.90, 15.00, 249.90, 1550, 1199, 1175);
  INSERT INTO PEDIDO VALUES (7330, TO_DATE('2026-02-01', 'YYYY-MM-DD'), '08:52', 'Entregado', 183.07, 10.00, 193.07, 1488, 1162, 1042);
  INSERT INTO PEDIDO VALUES (7331, TO_DATE('2026-02-19', 'YYYY-MM-DD'), '21:30', 'En preparación', 97.45, 10.00, 107.45, 1493, 1167, 1342);
  INSERT INTO PEDIDO VALUES (7332, TO_DATE('2026-02-23', 'YYYY-MM-DD'), '13:51', 'Entregado', 90.72, 12.50, 103.22, 1718, 1442, 1360);
  INSERT INTO PEDIDO VALUES (7333, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '19:25', 'Cancelado', 151.78, 15.00, 166.78, 1354, 1003, NULL);
  INSERT INTO PEDIDO VALUES (7334, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '12:28', 'Entregado', 153.25, 20.00, 173.25, 1735, 1459, 1121);
  INSERT INTO PEDIDO VALUES (7335, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '14:14', 'Entregado', 87.21, 15.00, 102.21, 1400, 1049, 1090);
  INSERT INTO PEDIDO VALUES (7336, TO_DATE('2026-04-03', 'YYYY-MM-DD'), '19:42', 'Entregado', 101.44, 12.50, 113.94, 1599, 1234, 1218);
  INSERT INTO PEDIDO VALUES (7337, TO_DATE('2026-01-20', 'YYYY-MM-DD'), '21:05', 'Cancelado', 219.00, 15.00, 234.00, 1419, 1068, 1109);
  INSERT INTO PEDIDO VALUES (7338, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '13:06', 'Entregado', 43.18, 15.00, 58.18, 1381, 1030, 1317);
  INSERT INTO PEDIDO VALUES (7339, TO_DATE('2026-03-19', 'YYYY-MM-DD'), '22:37', 'En camino', 246.33, 15.00, 261.33, 1461, 1135, 1056);
  INSERT INTO PEDIDO VALUES (7340, TO_DATE('2026-02-12', 'YYYY-MM-DD'), '13:40', 'Entregado', 183.18, 20.00, 203.18, 1696, 1345, 1198);
  INSERT INTO PEDIDO VALUES (7341, TO_DATE('2026-04-18', 'YYYY-MM-DD'), '19:49', 'En camino', 211.53, 20.00, 231.53, 1366, 1015, 1346);
  INSERT INTO PEDIDO VALUES (7342, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '19:26', 'Entregado', 201.21, 12.50, 213.71, 1357, 1006, 1241);
  INSERT INTO PEDIDO VALUES (7343, TO_DATE('2026-02-23', 'YYYY-MM-DD'), '21:03', 'Entregado', 233.15, 10.00, 243.15, 1555, 1204, 1108);
  INSERT INTO PEDIDO VALUES (7344, TO_DATE('2026-03-08', 'YYYY-MM-DD'), '14:38', 'Entregado', 222.18, 12.50, 234.68, 1550, 1199, 1007);
  INSERT INTO PEDIDO VALUES (7345, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '22:15', 'En preparación', 38.65, 15.00, 53.65, 1608, 1257, 1202);
  INSERT INTO PEDIDO VALUES (7346, TO_DATE('2026-01-09', 'YYYY-MM-DD'), '13:06', 'Entregado', 95.89, 15.00, 110.89, 1629, 1278, 1150);
  INSERT INTO PEDIDO VALUES (7347, TO_DATE('2026-01-21', 'YYYY-MM-DD'), '19:15', 'Entregado', 241.97, 12.50, 254.47, 1422, 1071, 1361);
  INSERT INTO PEDIDO VALUES (7348, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '21:38', 'Entregado', 183.18, 15.00, 198.18, 1468, 1142, 1259);
  INSERT INTO PEDIDO VALUES (7349, TO_DATE('2026-03-22', 'YYYY-MM-DD'), '13:30', 'Entregado', 113.68, 10.00, 123.68, 1515, 1150, 1172);
  INSERT INTO PEDIDO VALUES (7350, TO_DATE('2026-01-24', 'YYYY-MM-DD'), '08:48', 'Cancelado', 231.10, 20.00, 251.10, 1667, 1316, 1243);
  INSERT INTO PEDIDO VALUES (7351, TO_DATE('2026-04-10', 'YYYY-MM-DD'), '13:51', 'Entregado', 113.68, 10.00, 123.68, 1404, 1053, 1021);
  INSERT INTO PEDIDO VALUES (7352, TO_DATE('2026-01-08', 'YYYY-MM-DD'), '21:05', 'Entregado', 106.63, 10.00, 116.63, 1530, 1168, 1018);
  INSERT INTO PEDIDO VALUES (7353, TO_DATE('2026-01-03', 'YYYY-MM-DD'), '12:00', 'Entregado', 233.15, 12.50, 245.65, 1481, 1155, 1240);
  INSERT INTO PEDIDO VALUES (7354, TO_DATE('2026-02-27', 'YYYY-MM-DD'), '19:42', 'Entregado', 158.10, 20.00, 178.10, 1564, 1213, 1342);
  INSERT INTO PEDIDO VALUES (7355, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '13:06', 'Entregado', 38.65, 15.00, 53.65, 1435, 1099, 1056);
  INSERT INTO PEDIDO VALUES (7356, TO_DATE('2026-03-31', 'YYYY-MM-DD'), '14:26', 'En camino', 222.18, 15.00, 237.18, 1681, 1330, 1134);
  INSERT INTO PEDIDO VALUES (7357, TO_DATE('2026-04-19', 'YYYY-MM-DD'), '19:25', 'Cancelado', 142.14, 12.50, 154.64, 1381, 1030, NULL);
  INSERT INTO PEDIDO VALUES (7358, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '13:40', 'Entregado', 241.95, 20.00, 261.95, 1445, 1115, 1090);
  INSERT INTO PEDIDO VALUES (7359, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '21:30', 'Entregado', 208.97, 10.00, 218.97, 1419, 1068, 1175);
  INSERT INTO PEDIDO VALUES (7360, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '09:07', 'Entregado', 198.81, 12.50, 211.31, 1599, 1234, 1042);
  INSERT INTO PEDIDO VALUES (7361, TO_DATE('2026-03-08', 'YYYY-MM-DD'), '22:31', 'Entregado', 225.86, 12.50, 238.36, 1461, 1135, 1361);
  INSERT INTO PEDIDO VALUES (7362, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '13:06', 'Entregado', 104.97, 20.00, 124.97, 1357, 1006, 1109);
  INSERT INTO PEDIDO VALUES (7363, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '19:49', 'En preparación', 209.43, 20.00, 229.43, 1696, 1345, 1021);
  INSERT INTO PEDIDO VALUES (7364, TO_DATE('2026-04-21', 'YYYY-MM-DD'), '14:38', 'Entregado', 214.39, 10.00, 224.39, 1488, 1162, 1172);
  INSERT INTO PEDIDO VALUES (7365, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '21:03', 'En camino', 133.44, 15.00, 148.44, 1500, 1123, 1007);
  INSERT INTO PEDIDO VALUES (7366, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '22:15', 'Entregado', 69.24, 10.00, 79.24, 1735, 1459, 1317);
  INSERT INTO PEDIDO VALUES (7367, TO_DATE('2026-02-09', 'YYYY-MM-DD'), '13:30', 'Cancelado', 234.90, 15.00, 249.90, 1400, 1049, 1241);
  INSERT INTO PEDIDO VALUES (7368, TO_DATE('2026-02-01', 'YYYY-MM-DD'), '19:15', 'Entregado', 183.07, 15.00, 198.07, 1667, 1316, 1346);
  INSERT INTO PEDIDO VALUES (7369, TO_DATE('2026-02-19', 'YYYY-MM-DD'), '13:06', 'Cancelado', 97.45, 10.00, 107.45, 1515, 1150, 1218);
  INSERT INTO PEDIDO VALUES (7370, TO_DATE('2026-02-23', 'YYYY-MM-DD'), '14:14', 'En preparación', 233.15, 10.00, 243.15, 1608, 1257, 1202);
  INSERT INTO PEDIDO VALUES (7371, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '21:38', 'Entregado', 151.78, 15.00, 166.78, 1629, 1278, 1056);
  INSERT INTO PEDIDO VALUES (7372, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '13:51', 'Entregado', 153.25, 20.00, 173.25, 1718, 1442, 1198);
  INSERT INTO PEDIDO VALUES (7373, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '08:48', 'Entregado', 87.21, 15.00, 102.21, 1422, 1071, 1022);
  INSERT INTO PEDIDO VALUES (7374, TO_DATE('2026-04-03', 'YYYY-MM-DD'), '21:05', 'Cancelado', 101.44, 12.50, 113.94, 1461, 1135, NULL);
  INSERT INTO PEDIDO VALUES (7375, TO_DATE('2026-01-20', 'YYYY-MM-DD'), '13:06', 'Entregado', 167.33, 12.50, 179.83, 1381, 1030, 1259);
  INSERT INTO PEDIDO VALUES (7376, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '19:42', 'Entregado', 43.18, 15.00, 58.18, 1445, 1115, 1105);
  INSERT INTO PEDIDO VALUES (7377, TO_DATE('2026-03-19', 'YYYY-MM-DD'), '14:26', 'Entregado', 246.33, 15.00, 261.33, 1419, 1068, 1074);
  INSERT INTO PEDIDO VALUES (7378, TO_DATE('2026-02-12', 'YYYY-MM-DD'), '19:25', 'Cancelado', 183.18, 20.00, 203.18, 1488, 1162, 1134);
  INSERT INTO PEDIDO VALUES (7379, TO_DATE('2026-04-18', 'YYYY-MM-DD'), '13:40', 'Entregado', 241.80, 12.50, 254.30, 1599, 1234, 1301);
  INSERT INTO PEDIDO VALUES (7380, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '21:30', 'Entregado', 147.28, 10.00, 157.28, 1564, 1213, 1361);
  INSERT INTO PEDIDO VALUES (7381, TO_DATE('2026-04-12', 'YYYY-MM-DD'), '12:00', 'Entregado', 222.02, 12.50, 234.52, 1696, 1345, 1090);
  INSERT INTO PEDIDO VALUES (7382, TO_DATE('2026-04-10', 'YYYY-MM-DD'), '22:31', 'En preparación', 41.50, 12.50, 54.00, 1735, 1459, 1042);
  INSERT INTO PEDIDO VALUES (7383, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '19:49', 'Entregado', 65.55, 10.00, 75.55, 1400, 1049, 1342);
  INSERT INTO PEDIDO VALUES (7384, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '13:30', 'Entregado', 225.44, 20.00, 245.44, 1667, 1316, 1360);
  INSERT INTO PEDIDO VALUES (7385, TO_DATE('2026-04-19', 'YYYY-MM-DD'), '21:03', 'En camino', 225.86, 15.00, 240.86, 1629, 1278, 1092);
  INSERT INTO PEDIDO VALUES (7386, TO_DATE('2026-03-03', 'YYYY-MM-DD'), '13:06', 'Entregado', 188.75, 12.50, 201.25, 1422, 1071, 1021);
  INSERT INTO PEDIDO VALUES (7387, TO_DATE('2026-01-20', 'YYYY-MM-DD'), '14:38', 'En camino', 219.00, 15.00, 234.00, 1357, 1006, 1175);
  INSERT INTO PEDIDO VALUES (7388, TO_DATE('2026-04-16', 'YYYY-MM-DD'), '08:48', 'Cancelado', 113.88, 10.00, 123.88, 1681, 1330, 1121);
  INSERT INTO PEDIDO VALUES (7389, TO_DATE('2026-03-31', 'YYYY-MM-DD'), '13:51', 'Entregado', 234.33, 15.00, 249.33, 1461, 1135, 1198);
  INSERT INTO PEDIDO VALUES (7390, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '21:05', 'Entregado', 68.32, 20.00, 88.32, 1515, 1150, 1056);
  INSERT INTO PEDIDO VALUES (7391, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '19:42', 'Entregado', 106.33, 12.50, 118.83, 1530, 1168, 1317);
  INSERT INTO PEDIDO VALUES (7392, TO_DATE('2026-01-25', 'YYYY-MM-DD'), '19:15', 'En camino', 87.52, 12.50, 100.02, 1481, 1155, 1243);
  INSERT INTO PEDIDO VALUES (7393, TO_DATE('2026-02-14', 'YYYY-MM-DD'), '13:06', 'En preparación', 170.82, 10.00, 180.82, 1555, 1204, 1172);
  INSERT INTO PEDIDO VALUES (7394, TO_DATE('2026-03-02', 'YYYY-MM-DD'), '22:15', 'Entregado', 133.00, 12.50, 145.50, 1445, 1115, 1007);
  INSERT INTO PEDIDO VALUES (7395, TO_DATE('2026-01-16', 'YYYY-MM-DD'), '14:26', 'Entregado', 154.51, 10.00, 164.51, 1419, 1068, 1240);
  INSERT INTO PEDIDO VALUES (7396, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '13:40', 'Cancelado', 143.78, 15.00, 158.78, 1488, 1162, 1109);
  INSERT INTO PEDIDO VALUES (7397, TO_DATE('2026-04-18', 'YYYY-MM-DD'), '21:38', 'Entregado', 211.53, 20.00, 231.53, 1599, 1234, 1150);
  INSERT INTO PEDIDO VALUES (7398, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '19:25', 'Cancelado', 201.21, 12.50, 213.71, 1546, 1195, 1361);
  INSERT INTO PEDIDO VALUES (7399, TO_DATE('2026-02-23', 'YYYY-MM-DD'), '13:06', 'Entregado', 90.72, 12.50, 103.22, 1696, 1345, 1105);
  INSERT INTO PEDIDO VALUES (7400, TO_DATE('2026-03-08', 'YYYY-MM-DD'), '22:31', 'Cancelado', 222.18, 12.50, 234.68, 1718, 1442, 1342);
  COMMIT;
END;
 


BEGIN
  INSERT INTO PEDIDO VALUES (7401, TO_DATE('2026-04-16', 'YYYY-MM-DD'), '08:48', 'Entregado', 113.88, 10.00, 123.88, 1488, 1162, 1150);
  INSERT INTO PEDIDO VALUES (7402, TO_DATE('2026-03-31', 'YYYY-MM-DD'), '13:51', 'Entregado', 234.33, 15.00, 249.33, 1461, 1135, 1361);
  INSERT INTO PEDIDO VALUES (7403, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '21:03', 'En camino', 68.32, 20.00, 88.32, 1468, 1142, 1342);
  INSERT INTO PEDIDO VALUES (7404, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '22:31', 'Entregado', 106.33, 12.50, 118.83, 1696, 1345, 1360);
  INSERT INTO PEDIDO VALUES (7405, TO_DATE('2026-01-25', 'YYYY-MM-DD'), '13:06', 'Cancelado', 87.52, 12.50, 100.02, 1696, 1345, 1202);
  INSERT INTO PEDIDO VALUES (7406, TO_DATE('2026-02-14', 'YYYY-MM-DD'), '14:26', 'Entregado', 170.82, 10.00, 180.82, 1718, 1442, 1109);
  INSERT INTO PEDIDO VALUES (7407, TO_DATE('2026-03-02', 'YYYY-MM-DD'), '19:25', 'Entregado', 133.00, 12.50, 145.50, 1353, 1002, 1241);
  INSERT INTO PEDIDO VALUES (7408, TO_DATE('2026-01-16', 'YYYY-MM-DD'), '14:14', 'Entregado', 154.51, 10.00, 164.51, 1435, 1099, 1172);
  INSERT INTO PEDIDO VALUES (7409, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '13:06', 'Entregado', 143.78, 15.00, 158.78, 1481, 1155, 1346);
  INSERT INTO PEDIDO VALUES (7410, TO_DATE('2026-04-18', 'YYYY-MM-DD'), '21:38', 'Entregado', 211.53, 20.00, 231.53, 1564, 1213, 1090);
  INSERT INTO PEDIDO VALUES (7411, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '22:15', 'Cancelado', 201.21, 12.50, 213.71, 1735, 1459, 1240);
  INSERT INTO PEDIDO VALUES (7412, TO_DATE('2026-02-23', 'YYYY-MM-DD'), '19:49', 'Entregado', 90.72, 12.50, 103.22, 1400, 1049, 1021);
  INSERT INTO PEDIDO VALUES (7413, TO_DATE('2026-03-08', 'YYYY-MM-DD'), '13:30', 'Cancelado', 222.18, 12.50, 234.68, 1500, 1123, 1243);
  INSERT INTO PEDIDO VALUES (7414, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '21:05', 'Entregado', 211.75, 10.00, 221.75, 1699, 1348, NULL);
  INSERT INTO PEDIDO VALUES (7415, TO_DATE('2026-01-09', 'YYYY-MM-DD'), '08:48', 'Entregado', 95.89, 15.00, 110.89, 1493, 1167, 1056);
  INSERT INTO PEDIDO VALUES (7416, TO_DATE('2026-01-21', 'YYYY-MM-DD'), '13:51', 'Entregado', 241.97, 12.50, 254.47, 1667, 1316, 1175);
  INSERT INTO PEDIDO VALUES (7417, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '21:03', 'Entregado', 183.18, 15.00, 198.18, 1475, 1149, 1121);
  INSERT INTO PEDIDO VALUES (7418, TO_DATE('2026-03-22', 'YYYY-MM-DD'), '22:31', 'En preparación', 113.68, 10.00, 123.68, 1404, 1053, 1198);
  INSERT INTO PEDIDO VALUES (7419, TO_DATE('2026-01-24', 'YYYY-MM-DD'), '13:06', 'Entregado', 231.10, 20.00, 251.10, 1716, 1440, 1092);
  INSERT INTO PEDIDO VALUES (7420, TO_DATE('2026-04-10', 'YYYY-MM-DD'), '14:26', 'Entregado', 147.24, 20.00, 167.24, 1599, 1234, 1134);
  INSERT INTO PEDIDO VALUES (7421, TO_DATE('2026-01-08', 'YYYY-MM-DD'), '19:25', 'Cancelado', 106.63, 10.00, 116.63, 1530, 1168, 1150);
  INSERT INTO PEDIDO VALUES (7422, TO_DATE('2026-01-03', 'YYYY-MM-DD'), '14:14', 'Entregado', 233.15, 12.50, 245.65, 1608, 1257, 1361);
  INSERT INTO PEDIDO VALUES (7423, TO_DATE('2026-02-27', 'YYYY-MM-DD'), '13:06', 'Cancelado', 158.10, 20.00, 178.10, 1629, 1278, 1342);
  INSERT INTO PEDIDO VALUES (7424, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '21:38', 'Entregado', 38.65, 15.00, 53.65, 1422, 1071, 1360);
  INSERT INTO PEDIDO VALUES (7425, TO_DATE('2026-03-31', 'YYYY-MM-DD'), '22:15', 'En camino', 222.18, 15.00, 237.18, 1357, 1006, 1202);
  INSERT INTO PEDIDO VALUES (7426, TO_DATE('2026-04-19', 'YYYY-MM-DD'), '19:49', 'En camino', 142.14, 12.50, 154.64, 1667, 1316, 1109);
  INSERT INTO PEDIDO VALUES (7427, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '13:30', 'Entregado', 241.95, 20.00, 261.95, 1555, 1204, 1241);
  INSERT INTO PEDIDO VALUES (7428, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '21:05', 'Entregado', 208.97, 10.00, 218.97, 1550, 1199, 1172);
  INSERT INTO PEDIDO VALUES (7429, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '08:48', 'Cancelado', 198.81, 12.50, 211.31, 1381, 1030, 1346);
  INSERT INTO PEDIDO VALUES (7430, TO_DATE('2026-03-08', 'YYYY-MM-DD'), '13:51', 'Entregado', 225.86, 12.50, 238.36, 1445, 1115, 1090);
  INSERT INTO PEDIDO VALUES (7431, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '21:03', 'Entregado', 104.97, 20.00, 124.97, 1419, 1068, 1240);
  INSERT INTO PEDIDO VALUES (7432, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '22:31', 'Entregado', 209.43, 20.00, 229.43, 1488, 1162, 1021);
  INSERT INTO PEDIDO VALUES (7433, TO_DATE('2026-04-21', 'YYYY-MM-DD'), '13:06', 'Entregado', 214.39, 10.00, 224.39, 1461, 1135, 1243);
  INSERT INTO PEDIDO VALUES (7434, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '14:26', 'En camino', 133.44, 15.00, 148.44, 1468, 1142, NULL);
  INSERT INTO PEDIDO VALUES (7435, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '19:25', 'En camino', 69.24, 10.00, 79.24, 1696, 1345, 1056);
  INSERT INTO PEDIDO VALUES (7436, TO_DATE('2026-02-09', 'YYYY-MM-DD'), '14:14', 'Entregado', 234.90, 15.00, 249.90, 1696, 1345, 1175);
  INSERT INTO PEDIDO VALUES (7437, TO_DATE('2026-02-01', 'YYYY-MM-DD'), '13:06', 'Entregado', 183.07, 15.00, 198.07, 1718, 1442, 1121);
  INSERT INTO PEDIDO VALUES (7438, TO_DATE('2026-02-19', 'YYYY-MM-DD'), '21:38', 'En camino', 97.45, 10.00, 107.45, 1353, 1002, 1198);
  INSERT INTO PEDIDO VALUES (7439, TO_DATE('2026-02-23', 'YYYY-MM-DD'), '22:15', 'Entregado', 233.15, 10.00, 243.15, 1435, 1099, 1092);
  INSERT INTO PEDIDO VALUES (7440, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '19:49', 'Entregado', 151.78, 15.00, 166.78, 1481, 1155, 1134);
  INSERT INTO PEDIDO VALUES (7441, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '13:30', 'Entregado', 153.25, 20.00, 173.25, 1564, 1213, 1150);
  INSERT INTO PEDIDO VALUES (7442, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '21:05', 'En camino', 87.21, 15.00, 102.21, 1735, 1459, 1361);
  INSERT INTO PEDIDO VALUES (7443, TO_DATE('2026-04-03', 'YYYY-MM-DD'), '08:48', 'Entregado', 101.44, 12.50, 113.94, 1400, 1049, 1342);
  INSERT INTO PEDIDO VALUES (7444, TO_DATE('2026-01-20', 'YYYY-MM-DD'), '13:51', 'Entregado', 167.33, 12.50, 179.83, 1500, 1123, 1360);
  INSERT INTO PEDIDO VALUES (7445, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '21:03', 'Cancelado', 43.18, 15.00, 58.18, 1699, 1348, 1202);
  INSERT INTO PEDIDO VALUES (7446, TO_DATE('2026-03-19', 'YYYY-MM-DD'), '22:31', 'Entregado', 246.33, 15.00, 261.33, 1493, 1167, 1109);
  INSERT INTO PEDIDO VALUES (7447, TO_DATE('2026-02-12', 'YYYY-MM-DD'), '13:06', 'Entregado', 183.18, 20.00, 203.18, 1667, 1316, 1241);
  INSERT INTO PEDIDO VALUES (7448, TO_DATE('2026-04-18', 'YYYY-MM-DD'), '14:26', 'Entregado', 241.80, 12.50, 254.30, 1475, 1149, 1172);
  INSERT INTO PEDIDO VALUES (7449, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '19:25', 'Entregado', 147.28, 10.00, 157.28, 1404, 1053, 1346);
  INSERT INTO PEDIDO VALUES (7450, TO_DATE('2026-04-12', 'YYYY-MM-DD'), '14:14', 'En camino', 222.02, 12.50, 234.52, 1716, 1440, 1090);
  INSERT INTO PEDIDO VALUES (7451, TO_DATE('2026-04-10', 'YYYY-MM-DD'), '13:06', 'Entregado', 41.50, 12.50, 54.00, 1599, 1234, 1240);
  INSERT INTO PEDIDO VALUES (7452, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '21:38', 'Cancelado', 65.55, 10.00, 75.55, 1546, 1195, 1021);
  INSERT INTO PEDIDO VALUES (7453, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '22:15', 'Entregado', 225.44, 20.00, 245.44, 1517, 1152, 1243);
  INSERT INTO PEDIDO VALUES (7454, TO_DATE('2026-04-19', 'YYYY-MM-DD'), '19:49', 'Entregado', 225.86, 15.00, 240.86, 1528, 1163, NULL);
  INSERT INTO PEDIDO VALUES (7455, TO_DATE('2026-03-03', 'YYYY-MM-DD'), '13:30', 'Cancelado', 188.75, 12.50, 201.25, 1629, 1278, 1056);
  INSERT INTO PEDIDO VALUES (7456, TO_DATE('2026-01-20', 'YYYY-MM-DD'), '21:05', 'Entregado', 219.00, 15.00, 234.00, 1422, 1071, 1175);
  INSERT INTO PEDIDO VALUES (7457, TO_DATE('2026-04-16', 'YYYY-MM-DD'), '08:48', 'Entregado', 113.88, 10.00, 123.88, 1357, 1006, 1121);
  INSERT INTO PEDIDO VALUES (7458, TO_DATE('2026-03-31', 'YYYY-MM-DD'), '13:51', 'Entregado', 234.33, 15.00, 249.33, 1667, 1316, 1198);
  INSERT INTO PEDIDO VALUES (7459, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '21:03', 'En camino', 68.32, 20.00, 88.32, 1555, 1204, 1092);
  INSERT INTO PEDIDO VALUES (7460, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '22:31', 'Entregado', 106.33, 12.50, 118.83, 1550, 1199, 1134);
  INSERT INTO PEDIDO VALUES (7461, TO_DATE('2026-01-25', 'YYYY-MM-DD'), '13:06', 'Cancelado', 87.52, 12.50, 100.02, 1381, 1030, 1150);
  INSERT INTO PEDIDO VALUES (7462, TO_DATE('2026-02-14', 'YYYY-MM-DD'), '14:26', 'Entregado', 170.82, 10.00, 180.82, 1445, 1115, 1361);
  INSERT INTO PEDIDO VALUES (7463, TO_DATE('2026-03-02', 'YYYY-MM-DD'), '19:25', 'Entregado', 133.00, 12.50, 145.50, 1419, 1068, 1342);
  INSERT INTO PEDIDO VALUES (7464, TO_DATE('2026-01-16', 'YYYY-MM-DD'), '14:14', 'Entregado', 154.51, 10.00, 164.51, 1488, 1162, 1360);
  INSERT INTO PEDIDO VALUES (7465, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '13:06', 'Entregado', 143.78, 15.00, 158.78, 1461, 1135, 1202);
  INSERT INTO PEDIDO VALUES (7466, TO_DATE('2026-04-18', 'YYYY-MM-DD'), '21:38', 'Entregado', 211.53, 20.00, 231.53, 1468, 1142, 1109);
  INSERT INTO PEDIDO VALUES (7467, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '22:15', 'Cancelado', 201.21, 12.50, 213.71, 1696, 1345, 1241);
  INSERT INTO PEDIDO VALUES (7468, TO_DATE('2026-02-23', 'YYYY-MM-DD'), '19:49', 'Entregado', 90.72, 12.50, 103.22, 1696, 1345, 1172);
  INSERT INTO PEDIDO VALUES (7469, TO_DATE('2026-03-08', 'YYYY-MM-DD'), '13:30', 'Cancelado', 222.18, 12.50, 234.68, 1718, 1442, 1346);
  INSERT INTO PEDIDO VALUES (7470, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '21:05', 'Entregado', 211.75, 10.00, 221.75, 1353, 1002, 1090);
  INSERT INTO PEDIDO VALUES (7471, TO_DATE('2026-01-09', 'YYYY-MM-DD'), '08:48', 'Entregado', 95.89, 15.00, 110.89, 1435, 1099, 1240);
  INSERT INTO PEDIDO VALUES (7472, TO_DATE('2026-01-21', 'YYYY-MM-DD'), '13:51', 'Entregado', 241.97, 12.50, 254.47, 1481, 1155, 1021);
  INSERT INTO PEDIDO VALUES (7473, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '21:03', 'Entregado', 183.18, 15.00, 198.18, 1564, 1213, 1243);
  INSERT INTO PEDIDO VALUES (7474, TO_DATE('2026-03-22', 'YYYY-MM-DD'), '22:31', 'En preparación', 113.68, 10.00, 123.68, 1735, 1459, NULL);
  INSERT INTO PEDIDO VALUES (7475, TO_DATE('2026-01-24', 'YYYY-MM-DD'), '13:06', 'Entregado', 231.10, 20.00, 251.10, 1400, 1049, 1056);
  INSERT INTO PEDIDO VALUES (7476, TO_DATE('2026-04-10', 'YYYY-MM-DD'), '14:26', 'Entregado', 147.24, 20.00, 167.24, 1500, 1123, 1175);
  INSERT INTO PEDIDO VALUES (7477, TO_DATE('2026-01-08', 'YYYY-MM-DD'), '19:25', 'Cancelado', 106.63, 10.00, 116.63, 1699, 1348, 1121);
  INSERT INTO PEDIDO VALUES (7478, TO_DATE('2026-01-03', 'YYYY-MM-DD'), '14:14', 'Entregado', 233.15, 12.50, 245.65, 1493, 1167, 1198);
  INSERT INTO PEDIDO VALUES (7479, TO_DATE('2026-02-27', 'YYYY-MM-DD'), '13:06', 'Cancelado', 158.10, 20.00, 178.10, 1667, 1316, 1092);
  INSERT INTO PEDIDO VALUES (7480, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '21:38', 'Entregado', 38.65, 15.00, 53.65, 1475, 1149, 1134);
  INSERT INTO PEDIDO VALUES (7481, TO_DATE('2026-03-31', 'YYYY-MM-DD'), '22:15', 'En camino', 222.18, 15.00, 237.18, 1404, 1053, 1150);
  INSERT INTO PEDIDO VALUES (7482, TO_DATE('2026-04-19', 'YYYY-MM-DD'), '19:49', 'En camino', 142.14, 12.50, 154.64, 1716, 1440, 1349);
  INSERT INTO PEDIDO VALUES (7483, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '13:30', 'Entregado', 241.95, 20.00, 261.95, 1599, 1234, 1342);
  INSERT INTO PEDIDO VALUES (7484, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '21:05', 'Entregado', 208.97, 10.00, 218.97, 1546, 1195, 1297);
  INSERT INTO PEDIDO VALUES (7485, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '08:48', 'Cancelado', 198.81, 12.50, 211.31, 1517, 1152, 1202);
  INSERT INTO PEDIDO VALUES (7486, TO_DATE('2026-03-08', 'YYYY-MM-DD'), '13:51', 'Entregado', 225.86, 12.50, 238.36, 1528, 1163, 1109);
  INSERT INTO PEDIDO VALUES (7487, TO_DATE('2026-04-13', 'YYYY-MM-DD'), '21:03', 'Entregado', 104.97, 20.00, 124.97, 1629, 1278, 1241);
  INSERT INTO PEDIDO VALUES (7488, TO_DATE('2026-01-30', 'YYYY-MM-DD'), '22:31', 'Entregado', 209.43, 20.00, 229.43, 1422, 1071, 1172);
  INSERT INTO PEDIDO VALUES (7489, TO_DATE('2026-04-21', 'YYYY-MM-DD'), '13:06', 'Entregado', 214.39, 10.00, 224.39, 1357, 1006, 1346);
  INSERT INTO PEDIDO VALUES (7490, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '14:26', 'En camino', 133.44, 15.00, 148.44, 1667, 1316, 1090);
  INSERT INTO PEDIDO VALUES (7491, TO_DATE('2026-03-12', 'YYYY-MM-DD'), '19:25', 'En camino', 69.24, 10.00, 79.24, 1555, 1204, 1240);
  INSERT INTO PEDIDO VALUES (7492, TO_DATE('2026-02-09', 'YYYY-MM-DD'), '14:14', 'Entregado', 234.90, 15.00, 249.90, 1550, 1199, 1021);
  INSERT INTO PEDIDO VALUES (7493, TO_DATE('2026-02-01', 'YYYY-MM-DD'), '13:06', 'Entregado', 183.07, 15.00, 198.07, 1381, 1030, 1243);
  INSERT INTO PEDIDO VALUES (7494, TO_DATE('2026-02-19', 'YYYY-MM-DD'), '21:38', 'En camino', 97.45, 10.00, 107.45, 1445, 1115, NULL);
  INSERT INTO PEDIDO VALUES (7495, TO_DATE('2026-02-23', 'YYYY-MM-DD'), '22:15', 'Entregado', 233.15, 10.00, 243.15, 1419, 1068, 1056);
  INSERT INTO PEDIDO VALUES (7496, TO_DATE('2026-04-20', 'YYYY-MM-DD'), '19:49', 'Entregado', 151.78, 15.00, 166.78, 1488, 1162, 1175);
  INSERT INTO PEDIDO VALUES (7497, TO_DATE('2026-03-24', 'YYYY-MM-DD'), '13:30', 'Entregado', 153.25, 20.00, 173.25, 1461, 1135, 1121);
  INSERT INTO PEDIDO VALUES (7498, TO_DATE('2026-02-18', 'YYYY-MM-DD'), '21:05', 'En camino', 87.21, 15.00, 102.21, 1468, 1142, 1198);
  INSERT INTO PEDIDO VALUES (7499, TO_DATE('2026-04-03', 'YYYY-MM-DD'), '08:48', 'Entregado', 101.44, 12.50, 113.94, 1696, 1345, 1092);
  INSERT INTO PEDIDO VALUES (7500, TO_DATE('2026-01-20', 'YYYY-MM-DD'), '13:51', 'Entregado', 167.33, 12.50, 179.83, 1696, 1345, 1134);
  COMMIT;
END;



--CONTIENE 
--bloque 1
BEGIN
  INSERT INTO CONTIENE VALUES (7001, 6061, 4069, 4);
  INSERT INTO CONTIENE VALUES (7002, 6062, 4028, 3);
  INSERT INTO CONTIENE VALUES (7002, 6103, 4028, 3);
  INSERT INTO CONTIENE VALUES (7003, 6006, 4025, 1);
  INSERT INTO CONTIENE VALUES (7004, 6075, 4048, 2);
  INSERT INTO CONTIENE VALUES (7004, 6046, 4048, 3);
  INSERT INTO CONTIENE VALUES (7004, 6049, 4048, 2);
  INSERT INTO CONTIENE VALUES (7005, 6068, 4172, 1);
  INSERT INTO CONTIENE VALUES (7005, 6140, 4172, 2);
  INSERT INTO CONTIENE VALUES (7005, 6138, 4172, 2);
  INSERT INTO CONTIENE VALUES (7006, 6183, 4099, 1);
  INSERT INTO CONTIENE VALUES (7006, 6199, 4099, 3);
  INSERT INTO CONTIENE VALUES (7007, 6141, 4101, 2);
  INSERT INTO CONTIENE VALUES (7007, 6180, 4101, 1);
  INSERT INTO CONTIENE VALUES (7008, 6023, 4118, 4);
  INSERT INTO CONTIENE VALUES (7009, 6127, 4108, 4);
  INSERT INTO CONTIENE VALUES (7009, 6128, 4108, 2);
  INSERT INTO CONTIENE VALUES (7009, 6160, 4108, 2);
  INSERT INTO CONTIENE VALUES (7010, 6143, 4112, 1);
  INSERT INTO CONTIENE VALUES (7011, 6102, 4165, 3);
  INSERT INTO CONTIENE VALUES (7011, 6081, 4165, 3);
  INSERT INTO CONTIENE VALUES (7011, 6063, 4165, 2);
  INSERT INTO CONTIENE VALUES (7012, 6013, 4066, 1);
  INSERT INTO CONTIENE VALUES (7013, 6103, 4200, 3);
  INSERT INTO CONTIENE VALUES (7013, 6062, 4200, 3);
  INSERT INTO CONTIENE VALUES (7013, 6064, 4200, 2);
  INSERT INTO CONTIENE VALUES (7014, 6065, 4153, 4);
  INSERT INTO CONTIENE VALUES (7014, 6066, 4153, 3);
  INSERT INTO CONTIENE VALUES (7014, 6064, 4153, 1);
  INSERT INTO CONTIENE VALUES (7015, 6116, 4078, 1);
  INSERT INTO CONTIENE VALUES (7015, 6124, 4078, 4);
  INSERT INTO CONTIENE VALUES (7016, 6069, 4059, 1);
  INSERT INTO CONTIENE VALUES (7016, 6063, 4059, 1);
  INSERT INTO CONTIENE VALUES (7017, 6133, 4099, 1);
  INSERT INTO CONTIENE VALUES (7018, 6067, 4043, 4);
  INSERT INTO CONTIENE VALUES (7019, 6066, 4130, 4);
  INSERT INTO CONTIENE VALUES (7019, 6067, 4130, 4);
  INSERT INTO CONTIENE VALUES (7019, 6063, 4130, 1);
  INSERT INTO CONTIENE VALUES (7020, 6006, 4016, 1);
  INSERT INTO CONTIENE VALUES (7020, 6003, 4016, 1);
  INSERT INTO CONTIENE VALUES (7021, 6081, 4156, 3);
  INSERT INTO CONTIENE VALUES (7022, 6013, 4062, 2);
  INSERT INTO CONTIENE VALUES (7023, 6131, 4104, 3);
  INSERT INTO CONTIENE VALUES (7024, 6031, 4128, 4);
  INSERT INTO CONTIENE VALUES (7024, 6069, 4128, 1);
  INSERT INTO CONTIENE VALUES (7025, 6067, 4038, 2);
  INSERT INTO CONTIENE VALUES (7025, 6019, 4038, 2);
  INSERT INTO CONTIENE VALUES (7026, 6037, 4138, 2);
  INSERT INTO CONTIENE VALUES (7026, 6064, 4138, 3);
  INSERT INTO CONTIENE VALUES (7026, 6036, 4138, 3);
  INSERT INTO CONTIENE VALUES (7027, 6061, 4010, 1);
  INSERT INTO CONTIENE VALUES (7027, 6006, 4010, 3);
  INSERT INTO CONTIENE VALUES (7028, 6109, 4072, 4);
  INSERT INTO CONTIENE VALUES (7028, 6122, 4072, 3);
  INSERT INTO CONTIENE VALUES (7028, 6116, 4072, 1);
  INSERT INTO CONTIENE VALUES (7029, 6067, 4143, 2);
  INSERT INTO CONTIENE VALUES (7030, 6059, 4154, 4);
  INSERT INTO CONTIENE VALUES (7031, 6109, 4074, 1);
  INSERT INTO CONTIENE VALUES (7031, 6176, 4074, 3);
  INSERT INTO CONTIENE VALUES (7031, 6169, 4074, 1);
  INSERT INTO CONTIENE VALUES (7032, 6011, 4059, 3);
  INSERT INTO CONTIENE VALUES (7032, 6075, 4059, 4);
  INSERT INTO CONTIENE VALUES (7032, 6069, 4059, 2);
  INSERT INTO CONTIENE VALUES (7033, 6066, 4046, 3);
  INSERT INTO CONTIENE VALUES (7033, 6059, 4046, 3);
  INSERT INTO CONTIENE VALUES (7033, 6076, 4046, 2);
  INSERT INTO CONTIENE VALUES (7034, 6166, 4188, 3);
  INSERT INTO CONTIENE VALUES (7034, 6113, 4188, 1);
  INSERT INTO CONTIENE VALUES (7035, 6017, 4030, 1);
  INSERT INTO CONTIENE VALUES (7035, 6061, 4030, 2);
  INSERT INTO CONTIENE VALUES (7035, 6088, 4030, 2);
  INSERT INTO CONTIENE VALUES (7036, 6138, 4104, 3);
  INSERT INTO CONTIENE VALUES (7037, 6046, 4040, 2);
  INSERT INTO CONTIENE VALUES (7038, 6048, 4039, 4);
  INSERT INTO CONTIENE VALUES (7039, 6185, 4192, 1);
  INSERT INTO CONTIENE VALUES (7040, 6181, 4099, 1);
  INSERT INTO CONTIENE VALUES (7041, 6064, 4033, 4);
  INSERT INTO CONTIENE VALUES (7041, 6019, 4033, 2);
  INSERT INTO CONTIENE VALUES (7041, 6089, 4033, 2);
  INSERT INTO CONTIENE VALUES (7042, 6125, 4077, 4);
  INSERT INTO CONTIENE VALUES (7042, 6112, 4077, 4);
  INSERT INTO CONTIENE VALUES (7042, 6176, 4077, 2);
  INSERT INTO CONTIENE VALUES (7043, 6197, 4190, 4);
  INSERT INTO CONTIENE VALUES (7043, 6142, 4190, 3);
  INSERT INTO CONTIENE VALUES (7043, 6140, 4190, 4);
  INSERT INTO CONTIENE VALUES (7044, 6006, 4016, 2);
  INSERT INTO CONTIENE VALUES (7044, 6002, 4016, 3);
  INSERT INTO CONTIENE VALUES (7044, 6067, 4016, 2);
  INSERT INTO CONTIENE VALUES (7045, 6182, 4090, 1);
  INSERT INTO CONTIENE VALUES (7045, 6180, 4090, 3);
  INSERT INTO CONTIENE VALUES (7045, 6061, 4090, 1);
  INSERT INTO CONTIENE VALUES (7046, 6009, 4004, 1);
  INSERT INTO CONTIENE VALUES (7046, 6001, 4004, 1);
  INSERT INTO CONTIENE VALUES (7047, 6067, 4022, 1);
  INSERT INTO CONTIENE VALUES (7048, 6008, 4181, 2);
  INSERT INTO CONTIENE VALUES (7048, 6072, 4181, 4);
  INSERT INTO CONTIENE VALUES (7049, 6198, 4097, 3);
  INSERT INTO CONTIENE VALUES (7050, 6005, 4003, 3);
  INSERT INTO CONTIENE VALUES (7051, 6176, 4087, 4);
  INSERT INTO CONTIENE VALUES (7051, 6110, 4087, 3);
  COMMIT;
END;


--bloque 2
BEGIN
  INSERT INTO CONTIENE VALUES (7052, 6070, 4017, 3);
  INSERT INTO CONTIENE VALUES (7052, 6066, 4017, 4);
  INSERT INTO CONTIENE VALUES (7053, 6080, 4156, 4);
  INSERT INTO CONTIENE VALUES (7053, 6064, 4156, 1);
  INSERT INTO CONTIENE VALUES (7054, 6161, 4172, 1);
  INSERT INTO CONTIENE VALUES (7054, 6164, 4172, 4);
  INSERT INTO CONTIENE VALUES (7055, 6110, 4186, 3);
  INSERT INTO CONTIENE VALUES (7055, 6124, 4186, 4);
  INSERT INTO CONTIENE VALUES (7055, 6177, 4186, 1);
  INSERT INTO CONTIENE VALUES (7056, 6047, 4039, 4);
  INSERT INTO CONTIENE VALUES (7056, 6065, 4039, 3);
  INSERT INTO CONTIENE VALUES (7056, 6046, 4039, 3);
  INSERT INTO CONTIENE VALUES (7057, 6070, 4141, 1);
  INSERT INTO CONTIENE VALUES (7057, 6069, 4141, 2);
  INSERT INTO CONTIENE VALUES (7058, 6048, 4040, 2);
  INSERT INTO CONTIENE VALUES (7058, 6065, 4040, 3);
  INSERT INTO CONTIENE VALUES (7058, 6059, 4040, 3);
  INSERT INTO CONTIENE VALUES (7059, 6111, 4075, 4);
  INSERT INTO CONTIENE VALUES (7059, 6108, 4075, 3);
  INSERT INTO CONTIENE VALUES (7060, 6047, 4041, 3);
  INSERT INTO CONTIENE VALUES (7060, 6058, 4041, 4);
  INSERT INTO CONTIENE VALUES (7061, 6066, 4022, 1);
  INSERT INTO CONTIENE VALUES (7061, 6009, 4022, 1);
  INSERT INTO CONTIENE VALUES (7062, 6003, 4016, 2);
  INSERT INTO CONTIENE VALUES (7062, 6009, 4016, 3);
  INSERT INTO CONTIENE VALUES (7063, 6167, 4186, 1);
  INSERT INTO CONTIENE VALUES (7063, 6174, 4186, 3);
  INSERT INTO CONTIENE VALUES (7063, 6123, 4186, 4);
  INSERT INTO CONTIENE VALUES (7064, 6051, 4146, 3);
  INSERT INTO CONTIENE VALUES (7064, 6065, 4146, 4);
  INSERT INTO CONTIENE VALUES (7065, 6022, 4123, 4);
  INSERT INTO CONTIENE VALUES (7065, 6066, 4123, 2);
  INSERT INTO CONTIENE VALUES (7065, 6023, 4123, 3);
  INSERT INTO CONTIENE VALUES (7066, 6157, 4110, 2);
  INSERT INTO CONTIENE VALUES (7066, 6153, 4110, 4);
  INSERT INTO CONTIENE VALUES (7067, 6124, 4087, 4);
  INSERT INTO CONTIENE VALUES (7068, 6081, 4031, 3);
  INSERT INTO CONTIENE VALUES (7068, 6098, 4031, 4);
  INSERT INTO CONTIENE VALUES (7069, 6050, 4065, 3);
  INSERT INTO CONTIENE VALUES (7069, 6063, 4065, 1);
  INSERT INTO CONTIENE VALUES (7069, 6069, 4065, 2);
  INSERT INTO CONTIENE VALUES (7070, 6069, 4149, 3);
  INSERT INTO CONTIENE VALUES (7071, 6028, 4118, 3);
  INSERT INTO CONTIENE VALUES (7071, 6061, 4118, 1);
  INSERT INTO CONTIENE VALUES (7072, 6032, 4134, 1);
  INSERT INTO CONTIENE VALUES (7072, 6036, 4134, 2);
  INSERT INTO CONTIENE VALUES (7072, 6035, 4134, 1);
  INSERT INTO CONTIENE VALUES (7073, 6171, 4072, 4);
  INSERT INTO CONTIENE VALUES (7073, 6173, 4072, 4);
  INSERT INTO CONTIENE VALUES (7073, 6116, 4072, 4);
  INSERT INTO CONTIENE VALUES (7074, 6059, 4146, 3);
  INSERT INTO CONTIENE VALUES (7074, 6058, 4146, 4);
  INSERT INTO CONTIENE VALUES (7075, 6046, 4048, 1);
  INSERT INTO CONTIENE VALUES (7075, 6047, 4048, 2);
  INSERT INTO CONTIENE VALUES (7076, 6192, 4104, 2);
  INSERT INTO CONTIENE VALUES (7077, 6081, 4157, 1);
  INSERT INTO CONTIENE VALUES (7077, 6061, 4157, 3);
  INSERT INTO CONTIENE VALUES (7077, 6101, 4157, 1);
  INSERT INTO CONTIENE VALUES (7078, 6135, 4192, 2);
  INSERT INTO CONTIENE VALUES (7078, 6069, 4192, 1);
  INSERT INTO CONTIENE VALUES (7078, 6064, 4192, 2);
  INSERT INTO CONTIENE VALUES (7079, 6157, 4178, 3);
  INSERT INTO CONTIENE VALUES (7080, 6054, 4149, 3);
  INSERT INTO CONTIENE VALUES (7080, 6069, 4149, 1);
  INSERT INTO CONTIENE VALUES (7081, 6058, 4050, 4);
  INSERT INTO CONTIENE VALUES (7082, 6006, 4022, 1);
  INSERT INTO CONTIENE VALUES (7082, 6004, 4022, 4);
  INSERT INTO CONTIENE VALUES (7082, 6002, 4022, 1);
  INSERT INTO CONTIENE VALUES (7083, 6070, 4040, 2);
  INSERT INTO CONTIENE VALUES (7083, 6060, 4040, 2);
  INSERT INTO CONTIENE VALUES (7084, 6140, 4110, 4);
  INSERT INTO CONTIENE VALUES (7084, 6067, 4110, 2);
  INSERT INTO CONTIENE VALUES (7085, 6132, 4099, 1);
  INSERT INTO CONTIENE VALUES (7085, 6135, 4099, 1);
  INSERT INTO CONTIENE VALUES (7085, 6141, 4099, 3);
  INSERT INTO CONTIENE VALUES (7086, 6127, 4104, 4);
  INSERT INTO CONTIENE VALUES (7086, 6185, 4104, 3);
  INSERT INTO CONTIENE VALUES (7087, 6146, 4109, 3);
  INSERT INTO CONTIENE VALUES (7088, 6047, 4040, 3);
  INSERT INTO CONTIENE VALUES (7088, 6046, 4040, 3);
  INSERT INTO CONTIENE VALUES (7089, 6013, 4066, 1);
  INSERT INTO CONTIENE VALUES (7089, 6075, 4066, 2);
  INSERT INTO CONTIENE VALUES (7090, 6081, 4030, 1);
  INSERT INTO CONTIENE VALUES (7090, 6069, 4030, 2);
  INSERT INTO CONTIENE VALUES (7090, 6065, 4030, 3);
  INSERT INTO CONTIENE VALUES (7091, 6023, 4124, 2);
  INSERT INTO CONTIENE VALUES (7091, 6026, 4124, 3);
  INSERT INTO CONTIENE VALUES (7091, 6022, 4124, 1);
  INSERT INTO CONTIENE VALUES (7092, 6157, 4109, 4);
  INSERT INTO CONTIENE VALUES (7092, 6064, 4109, 2);
  INSERT INTO CONTIENE VALUES (7093, 6037, 4136, 1);
  INSERT INTO CONTIENE VALUES (7093, 6035, 4136, 1);
  INSERT INTO CONTIENE VALUES (7094, 6141, 4108, 1);
  INSERT INTO CONTIENE VALUES (7094, 6158, 4108, 4);
  INSERT INTO CONTIENE VALUES (7094, 6144, 4108, 1);
  INSERT INTO CONTIENE VALUES (7095, 6059, 4153, 3);
  INSERT INTO CONTIENE VALUES (7095, 6056, 4153, 2);
  INSERT INTO CONTIENE VALUES (7096, 6116, 4087, 4);
  INSERT INTO CONTIENE VALUES (7096, 6177, 4087, 1);
  INSERT INTO CONTIENE VALUES (7096, 6175, 4087, 4);
  INSERT INTO CONTIENE VALUES (7097, 6197, 4192, 4);
  INSERT INTO CONTIENE VALUES (7097, 6137, 4192, 4);
  INSERT INTO CONTIENE VALUES (7097, 6184, 4192, 2);
  INSERT INTO CONTIENE VALUES (7098, 6006, 4015, 3);
  INSERT INTO CONTIENE VALUES (7099, 6127, 4099, 4);
  INSERT INTO CONTIENE VALUES (7099, 6186, 4099, 2);
  INSERT INTO CONTIENE VALUES (7100, 6046, 4048, 1);
  INSERT INTO CONTIENE VALUES (7100, 6060, 4048, 1);
  INSERT INTO CONTIENE VALUES (7100, 6059, 4048, 1);
  COMMIT;
END;

--bloque 3
BEGIN
  INSERT INTO CONTIENE VALUES (7099, 6102, 4200, 3);
  INSERT INTO CONTIENE VALUES (7100, 6064, 4007, 4);
  INSERT INTO CONTIENE VALUES (7101, 6052, 4146, 2);
  INSERT INTO CONTIENE VALUES (7101, 6068, 4146, 3);
  INSERT INTO CONTIENE VALUES (7102, 6068, 4153, 1);
  INSERT INTO CONTIENE VALUES (7102, 6061, 4153, 2);
  INSERT INTO CONTIENE VALUES (7103, 6106, 4073, 2);
  INSERT INTO CONTIENE VALUES (7103, 6121, 4073, 4);
  INSERT INTO CONTIENE VALUES (7104, 6148, 4109, 2);
  INSERT INTO CONTIENE VALUES (7105, 6147, 4171, 2);
  INSERT INTO CONTIENE VALUES (7106, 6069, 4115, 2);
  INSERT INTO CONTIENE VALUES (7107, 6064, 4146, 3);
  INSERT INTO CONTIENE VALUES (7107, 6068, 4146, 1);
  INSERT INTO CONTIENE VALUES (7108, 6002, 4023, 1);
  INSERT INTO CONTIENE VALUES (7109, 6167, 4080, 2);
  INSERT INTO CONTIENE VALUES (7109, 6107, 4080, 1);
  INSERT INTO CONTIENE VALUES (7109, 6168, 4080, 1);
  INSERT INTO CONTIENE VALUES (7110, 6124, 4188, 3);
  INSERT INTO CONTIENE VALUES (7110, 6118, 4188, 2);
  INSERT INTO CONTIENE VALUES (7111, 6158, 4169, 1);
  INSERT INTO CONTIENE VALUES (7111, 6159, 4169, 1);
  INSERT INTO CONTIENE VALUES (7111, 6062, 4169, 1);
  INSERT INTO CONTIENE VALUES (7112, 6075, 4039, 3);
  INSERT INTO CONTIENE VALUES (7113, 6064, 4131, 3);
  INSERT INTO CONTIENE VALUES (7113, 6039, 4131, 4);
  INSERT INTO CONTIENE VALUES (7114, 6067, 4137, 1);
  INSERT INTO CONTIENE VALUES (7115, 6070, 4149, 2);
  INSERT INTO CONTIENE VALUES (7116, 6070, 4195, 2);
  INSERT INTO CONTIENE VALUES (7116, 6034, 4195, 4);
  INSERT INTO CONTIENE VALUES (7116, 6065, 4195, 1);
  INSERT INTO CONTIENE VALUES (7117, 6123, 4076, 3);
  INSERT INTO CONTIENE VALUES (7117, 6117, 4076, 3);
  INSERT INTO CONTIENE VALUES (7118, 6049, 4044, 3);
  INSERT INTO CONTIENE VALUES (7119, 6054, 4150, 4);
  INSERT INTO CONTIENE VALUES (7120, 6064, 4194, 1);
  INSERT INTO CONTIENE VALUES (7120, 6026, 4194, 1);
  INSERT INTO CONTIENE VALUES (7121, 6063, 4147, 2);
  INSERT INTO CONTIENE VALUES (7122, 6063, 4174, 4);
  INSERT INTO CONTIENE VALUES (7122, 6149, 4174, 2);
  INSERT INTO CONTIENE VALUES (7122, 6065, 4174, 4);
  INSERT INTO CONTIENE VALUES (7123, 6120, 4081, 3);
  INSERT INTO CONTIENE VALUES (7123, 6111, 4081, 4);
  INSERT INTO CONTIENE VALUES (7124, 6062, 4061, 1);
  INSERT INTO CONTIENE VALUES (7125, 6035, 4133, 2);
  INSERT INTO CONTIENE VALUES (7125, 6062, 4133, 2);
  INSERT INTO CONTIENE VALUES (7125, 6032, 4133, 2);
  INSERT INTO CONTIENE VALUES (7126, 6158, 4176, 2);
  INSERT INTO CONTIENE VALUES (7126, 6064, 4176, 2);
  INSERT INTO CONTIENE VALUES (7126, 6066, 4176, 2);
  INSERT INTO CONTIENE VALUES (7127, 6031, 4129, 2);
  INSERT INTO CONTIENE VALUES (7127, 6066, 4129, 3);
  INSERT INTO CONTIENE VALUES (7128, 6162, 4174, 4);
  INSERT INTO CONTIENE VALUES (7128, 6061, 4174, 2);
  INSERT INTO CONTIENE VALUES (7129, 6141, 4110, 4);
  INSERT INTO CONTIENE VALUES (7130, 6169, 4082, 4);
  INSERT INTO CONTIENE VALUES (7130, 6121, 4082, 1);
  INSERT INTO CONTIENE VALUES (7131, 6065, 4114, 1);
  INSERT INTO CONTIENE VALUES (7131, 6021, 4114, 1);
  INSERT INTO CONTIENE VALUES (7132, 6198, 4091, 2);
  INSERT INTO CONTIENE VALUES (7132, 6195, 4091, 4);
  INSERT INTO CONTIENE VALUES (7132, 6140, 4091, 3);
  INSERT INTO CONTIENE VALUES (7133, 6050, 4060, 4);
  INSERT INTO CONTIENE VALUES (7133, 6064, 4060, 2);
  INSERT INTO CONTIENE VALUES (7133, 6063, 4060, 4);
  INSERT INTO CONTIENE VALUES (7134, 6080, 4164, 2);
  INSERT INTO CONTIENE VALUES (7134, 6101, 4164, 3);
  INSERT INTO CONTIENE VALUES (7135, 6060, 4140, 3);
  INSERT INTO CONTIENE VALUES (7135, 6053, 4140, 2);
  INSERT INTO CONTIENE VALUES (7136, 6104, 4031, 2);
  INSERT INTO CONTIENE VALUES (7137, 6007, 4003, 4);
  INSERT INTO CONTIENE VALUES (7137, 6003, 4003, 4);
  INSERT INTO CONTIENE VALUES (7137, 6004, 4003, 4);
  INSERT INTO CONTIENE VALUES (7138, 6076, 4049, 3);
  INSERT INTO CONTIENE VALUES (7139, 6120, 4085, 4);
  INSERT INTO CONTIENE VALUES (7140, 6179, 4102, 3);
  INSERT INTO CONTIENE VALUES (7141, 6181, 4097, 1);
  INSERT INTO CONTIENE VALUES (7141, 6187, 4097, 1);
  INSERT INTO CONTIENE VALUES (7141, 6191, 4097, 3);
  INSERT INTO CONTIENE VALUES (7142, 6050, 4049, 1);
  INSERT INTO CONTIENE VALUES (7143, 6104, 4166, 4);
  INSERT INTO CONTIENE VALUES (7143, 6103, 4166, 1);
  INSERT INTO CONTIENE VALUES (7144, 6064, 4014, 4);
  INSERT INTO CONTIENE VALUES (7144, 6070, 4014, 4);
  INSERT INTO CONTIENE VALUES (7145, 6117, 4086, 3);
  INSERT INTO CONTIENE VALUES (7145, 6116, 4086, 2);
  INSERT INTO CONTIENE VALUES (7145, 6170, 4086, 1);
  INSERT INTO CONTIENE VALUES (7146, 6063, 4114, 3);
  INSERT INTO CONTIENE VALUES (7147, 6068, 4053, 3);
  INSERT INTO CONTIENE VALUES (7148, 6175, 4074, 3);
  INSERT INTO CONTIENE VALUES (7148, 6114, 4074, 2);
  INSERT INTO CONTIENE VALUES (7148, 6124, 4074, 1);
  INSERT INTO CONTIENE VALUES (7149, 6025, 4121, 2);
  INSERT INTO CONTIENE VALUES (7149, 6027, 4121, 4);
  INSERT INTO CONTIENE VALUES (7149, 6061, 4121, 2);
  INSERT INTO CONTIENE VALUES (7150, 6056, 4199, 4);
  INSERT INTO CONTIENE VALUES (7150, 6057, 4199, 4);
  INSERT INTO CONTIENE VALUES (7151, 6065, 4122, 3);
  INSERT INTO CONTIENE VALUES (7151, 6070, 4122, 4);
  INSERT INTO CONTIENE VALUES (7152, 6171, 4076, 1);
  INSERT INTO CONTIENE VALUES (7152, 6119, 4076, 3);
  COMMIT;
END;

--bloque 4
BEGIN
  INSERT INTO CONTIENE VALUES (7152, 6123, 4076, 4);
  INSERT INTO CONTIENE VALUES (7153, 6070, 4145, 2);
  INSERT INTO CONTIENE VALUES (7153, 6067, 4145, 1);
  INSERT INTO CONTIENE VALUES (7153, 6055, 4145, 2);
  INSERT INTO CONTIENE VALUES (7154, 6126, 4107, 3);
  INSERT INTO CONTIENE VALUES (7154, 6067, 4107, 2);
  INSERT INTO CONTIENE VALUES (7154, 6137, 4107, 3);
  INSERT INTO CONTIENE VALUES (7155, 6038, 4134, 4);
  INSERT INTO CONTIENE VALUES (7156, 6006, 4022, 1);
  INSERT INTO CONTIENE VALUES (7156, 6103, 4022, 3);
  INSERT INTO CONTIENE VALUES (7156, 6005, 4022, 4);
  INSERT INTO CONTIENE VALUES (7157, 6062, 4162, 2);
  INSERT INTO CONTIENE VALUES (7157, 6063, 4162, 2);
  INSERT INTO CONTIENE VALUES (7157, 6101, 4162, 3);
  INSERT INTO CONTIENE VALUES (7158, 6076, 4040, 3);
  INSERT INTO CONTIENE VALUES (7158, 6044, 4040, 2);
  INSERT INTO CONTIENE VALUES (7159, 6068, 4051, 3);
  INSERT INTO CONTIENE VALUES (7159, 6065, 4051, 2);
  INSERT INTO CONTIENE VALUES (7159, 6050, 4051, 4);
  INSERT INTO CONTIENE VALUES (7160, 6076, 4047, 3);
  INSERT INTO CONTIENE VALUES (7161, 6066, 4171, 1);
  INSERT INTO CONTIENE VALUES (7161, 6151, 4171, 1);
  INSERT INTO CONTIENE VALUES (7161, 6156, 4171, 2);
  INSERT INTO CONTIENE VALUES (7162, 6188, 4089, 1);
  INSERT INTO CONTIENE VALUES (7163, 6064, 4119, 2);
  INSERT INTO CONTIENE VALUES (7164, 6067, 4143, 1);
  INSERT INTO CONTIENE VALUES (7165, 6153, 4169, 4);
  INSERT INTO CONTIENE VALUES (7165, 6061, 4169, 2);
  INSERT INTO CONTIENE VALUES (7165, 6149, 4169, 2);
  INSERT INTO CONTIENE VALUES (7166, 6176, 4079, 3);
  INSERT INTO CONTIENE VALUES (7166, 6122, 4079, 4);
  INSERT INTO CONTIENE VALUES (7166, 6174, 4079, 1);
  INSERT INTO CONTIENE VALUES (7167, 6030, 4125, 2);
  INSERT INTO CONTIENE VALUES (7167, 6064, 4125, 2);
  INSERT INTO CONTIENE VALUES (7167, 6069, 4125, 2);
  INSERT INTO CONTIENE VALUES (7168, 6122, 4077, 2);
  INSERT INTO CONTIENE VALUES (7169, 6057, 4151, 2);
  INSERT INTO CONTIENE VALUES (7169, 6056, 4151, 2);
  INSERT INTO CONTIENE VALUES (7169, 6067, 4151, 4);
  INSERT INTO CONTIENE VALUES (7170, 6063, 4031, 1);
  INSERT INTO CONTIENE VALUES (7170, 6088, 4031, 4);
  INSERT INTO CONTIENE VALUES (7170, 6068, 4031, 4);
  INSERT INTO CONTIENE VALUES (7171, 6058, 4142, 4);
  INSERT INTO CONTIENE VALUES (7172, 6069, 4020, 3);
  INSERT INTO CONTIENE VALUES (7172, 6005, 4020, 2);
  INSERT INTO CONTIENE VALUES (7172, 6070, 4020, 2);
  INSERT INTO CONTIENE VALUES (7173, 6065, 4053, 4);
  INSERT INTO CONTIENE VALUES (7173, 6016, 4053, 3);
  INSERT INTO CONTIENE VALUES (7173, 6061, 4053, 4);
  INSERT INTO CONTIENE VALUES (7174, 6044, 4048, 3);
  INSERT INTO CONTIENE VALUES (7175, 6001, 4019, 1);
  INSERT INTO CONTIENE VALUES (7175, 6005, 4019, 4);
  INSERT INTO CONTIENE VALUES (7175, 6070, 4019, 1);
  INSERT INTO CONTIENE VALUES (7176, 6069, 4068, 2);
  INSERT INTO CONTIENE VALUES (7177, 6137, 4192, 3);
  INSERT INTO CONTIENE VALUES (7177, 6066, 4192, 1);
  INSERT INTO CONTIENE VALUES (7178, 6066, 4127, 1);
  INSERT INTO CONTIENE VALUES (7178, 6062, 4127, 2);
  INSERT INTO CONTIENE VALUES (7178, 6069, 4127, 3);
  INSERT INTO CONTIENE VALUES (7179, 6067, 4066, 1);
  INSERT INTO CONTIENE VALUES (7179, 6014, 4066, 1);
  INSERT INTO CONTIENE VALUES (7179, 6012, 4066, 1);
  INSERT INTO CONTIENE VALUES (7180, 6041, 4183, 4);
  INSERT INTO CONTIENE VALUES (7180, 6047, 4183, 4);
  INSERT INTO CONTIENE VALUES (7180, 6044, 4183, 2);
  INSERT INTO CONTIENE VALUES (7181, 6064, 4062, 3);
  INSERT INTO CONTIENE VALUES (7182, 6076, 4185, 2);
  INSERT INTO CONTIENE VALUES (7183, 6058, 4141, 4);
  INSERT INTO CONTIENE VALUES (7183, 6064, 4141, 2);
  INSERT INTO CONTIENE VALUES (7183, 6062, 4141, 3);
  INSERT INTO CONTIENE VALUES (7184, 6140, 4094, 4);
  INSERT INTO CONTIENE VALUES (7184, 6200, 4094, 1);
  INSERT INTO CONTIENE VALUES (7184, 6063, 4094, 2);
  INSERT INTO CONTIENE VALUES (7185, 6015, 4058, 2);
  INSERT INTO CONTIENE VALUES (7185, 6066, 4058, 3);
  INSERT INTO CONTIENE VALUES (7186, 6070, 4183, 4);
  INSERT INTO CONTIENE VALUES (7186, 6048, 4183, 3);
  INSERT INTO CONTIENE VALUES (7187, 6147, 4172, 1);
  INSERT INTO CONTIENE VALUES (7187, 6153, 4172, 3);
  INSERT INTO CONTIENE VALUES (7188, 6064, 4070, 4);
  INSERT INTO CONTIENE VALUES (7189, 6065, 4172, 2);
  INSERT INTO CONTIENE VALUES (7190, 6035, 4136, 2);
  INSERT INTO CONTIENE VALUES (7191, 6119, 4071, 4);
  INSERT INTO CONTIENE VALUES (7191, 6124, 4071, 4);
  INSERT INTO CONTIENE VALUES (7191, 6169, 4071, 3);
  INSERT INTO CONTIENE VALUES (7192, 6156, 4170, 1);
  INSERT INTO CONTIENE VALUES (7192, 6066, 4170, 2);
  INSERT INTO CONTIENE VALUES (7192, 6150, 4170, 4);
  INSERT INTO CONTIENE VALUES (7193, 6171, 4078, 4);
  INSERT INTO CONTIENE VALUES (7193, 6117, 4078, 3);
  INSERT INTO CONTIENE VALUES (7193, 6176, 4078, 4);
  INSERT INTO CONTIENE VALUES (7194, 6067, 4191, 1);
  INSERT INTO CONTIENE VALUES (7194, 6130, 4191, 2);
  INSERT INTO CONTIENE VALUES (7194, 6061, 4191, 2);
  INSERT INTO CONTIENE VALUES (7195, 6064, 4197, 1);
  INSERT INTO CONTIENE VALUES (7195, 6058, 4197, 4);
  INSERT INTO CONTIENE VALUES (7196, 6101, 4160, 2);
  INSERT INTO CONTIENE VALUES (7197, 6016, 4057, 1);
  INSERT INTO CONTIENE VALUES (7198, 6068, 4131, 4);
  INSERT INTO CONTIENE VALUES (7199, 6105, 4161, 3);
  INSERT INTO CONTIENE VALUES (7199, 6067, 4161, 4);
  INSERT INTO CONTIENE VALUES (7199, 6064, 4161, 2);
  INSERT INTO CONTIENE VALUES (7200, 6064, 4160, 2);
  INSERT INTO CONTIENE VALUES (7200, 6070, 4160, 3);
  INSERT INTO CONTIENE VALUES (7200, 6081, 4160, 3);
  COMMIT;
END;

--bloque 5
BEGIN
  INSERT INTO CONTIENE VALUES (7204, 6063, 4195, 2);
  INSERT INTO CONTIENE VALUES (7205, 6068, 4051, 4);
  INSERT INTO CONTIENE VALUES (7205, 6075, 4051, 3);
  INSERT INTO CONTIENE VALUES (7205, 6066, 4051, 2);
  INSERT INTO CONTIENE VALUES (7206, 6112, 4085, 4);
  INSERT INTO CONTIENE VALUES (7206, 6124, 4085, 3);
  INSERT INTO CONTIENE VALUES (7206, 6110, 4085, 3);
  INSERT INTO CONTIENE VALUES (7207, 6066, 4118, 1);
  INSERT INTO CONTIENE VALUES (7208, 6066, 4035, 3);
  INSERT INTO CONTIENE VALUES (7208, 6096, 4035, 4);
  INSERT INTO CONTIENE VALUES (7208, 6020, 4035, 4);
  INSERT INTO CONTIENE VALUES (7209, 6065, 4055, 2);
  INSERT INTO CONTIENE VALUES (7209, 6069, 4055, 2);
  INSERT INTO CONTIENE VALUES (7209, 6016, 4055, 2);
  INSERT INTO CONTIENE VALUES (7210, 6082, 4033, 2);
  INSERT INTO CONTIENE VALUES (7210, 6081, 4033, 4);
  INSERT INTO CONTIENE VALUES (7210, 6096, 4033, 4);
  INSERT INTO CONTIENE VALUES (7211, 6048, 4049, 2);
  INSERT INTO CONTIENE VALUES (7211, 6050, 4049, 2);
  INSERT INTO CONTIENE VALUES (7211, 6059, 4049, 1);
  INSERT INTO CONTIENE VALUES (7212, 6115, 4088, 4);
  INSERT INTO CONTIENE VALUES (7212, 6107, 4088, 4);
  INSERT INTO CONTIENE VALUES (7213, 6005, 4017, 4);
  INSERT INTO CONTIENE VALUES (7213, 6070, 4017, 2);
  INSERT INTO CONTIENE VALUES (7213, 6008, 4017, 4);
  INSERT INTO CONTIENE VALUES (7214, 6108, 4084, 3);
  INSERT INTO CONTIENE VALUES (7215, 6168, 4186, 3);
  INSERT INTO CONTIENE VALUES (7215, 6177, 4186, 4);
  INSERT INTO CONTIENE VALUES (7215, 6121, 4186, 1);
  INSERT INTO CONTIENE VALUES (7216, 6031, 4128, 1);
  INSERT INTO CONTIENE VALUES (7217, 6066, 4017, 1);
  INSERT INTO CONTIENE VALUES (7217, 6010, 4017, 2);
  INSERT INTO CONTIENE VALUES (7218, 6064, 4166, 2);
  INSERT INTO CONTIENE VALUES (7218, 6066, 4166, 2);
  INSERT INTO CONTIENE VALUES (7219, 6021, 4114, 1);
  INSERT INTO CONTIENE VALUES (7220, 6037, 4130, 4);
  INSERT INTO CONTIENE VALUES (7221, 6055, 4142, 4);
  INSERT INTO CONTIENE VALUES (7221, 6056, 4142, 4);
  INSERT INTO CONTIENE VALUES (7222, 6165, 4172, 4);
  INSERT INTO CONTIENE VALUES (7222, 6153, 4172, 1);
  INSERT INTO CONTIENE VALUES (7222, 6149, 4172, 4);
  INSERT INTO CONTIENE VALUES (7223, 6064, 4169, 3);
  INSERT INTO CONTIENE VALUES (7224, 6065, 4019, 2);
  INSERT INTO CONTIENE VALUES (7224, 6002, 4019, 2);
  INSERT INTO CONTIENE VALUES (7224, 6006, 4019, 2);
  INSERT INTO CONTIENE VALUES (7225, 6064, 4063, 1);
  INSERT INTO CONTIENE VALUES (7226, 6070, 4197, 1);
  INSERT INTO CONTIENE VALUES (7226, 6060, 4197, 2);
  INSERT INTO CONTIENE VALUES (7227, 6009, 4002, 3);
  INSERT INTO CONTIENE VALUES (7228, 6182, 4093, 3);
  INSERT INTO CONTIENE VALUES (7228, 6190, 4093, 1);
  INSERT INTO CONTIENE VALUES (7229, 6010, 4180, 3);
  INSERT INTO CONTIENE VALUES (7230, 6067, 4198, 4);
  INSERT INTO CONTIENE VALUES (7231, 6196, 4095, 4);
  INSERT INTO CONTIENE VALUES (7232, 6013, 4054, 1);
  INSERT INTO CONTIENE VALUES (7232, 6075, 4054, 1);
  INSERT INTO CONTIENE VALUES (7232, 6011, 4054, 1);
  INSERT INTO CONTIENE VALUES (7233, 6003, 4026, 4);
  INSERT INTO CONTIENE VALUES (7234, 6067, 4134, 1);
  INSERT INTO CONTIENE VALUES (7235, 6107, 4186, 2);
  INSERT INTO CONTIENE VALUES (7235, 6116, 4186, 2);
  INSERT INTO CONTIENE VALUES (7235, 6175, 4186, 3);
  INSERT INTO CONTIENE VALUES (7236, 6002, 4017, 1);
  INSERT INTO CONTIENE VALUES (7236, 6061, 4017, 3);
  INSERT INTO CONTIENE VALUES (7237, 6069, 4020, 4);
  INSERT INTO CONTIENE VALUES (7237, 6001, 4020, 3);
  INSERT INTO CONTIENE VALUES (7237, 6009, 4020, 1);
  INSERT INTO CONTIENE VALUES (7238, 6025, 4119, 3);
  INSERT INTO CONTIENE VALUES (7239, 6126, 4190, 3);
  INSERT INTO CONTIENE VALUES (7239, 6195, 4190, 2);
  INSERT INTO CONTIENE VALUES (7239, 6069, 4190, 2);
  INSERT INTO CONTIENE VALUES (7240, 6104, 4166, 3);
  INSERT INTO CONTIENE VALUES (7241, 6003, 4024, 2);
  INSERT INTO CONTIENE VALUES (7242, 6190, 4102, 4);
  INSERT INTO CONTIENE VALUES (7242, 6135, 4102, 3);
  INSERT INTO CONTIENE VALUES (7243, 6068, 4138, 1);
  INSERT INTO CONTIENE VALUES (7243, 6039, 4138, 1);
  INSERT INTO CONTIENE VALUES (7244, 6150, 4175, 4);
  INSERT INTO CONTIENE VALUES (7244, 6161, 4175, 2);
  INSERT INTO CONTIENE VALUES (7245, 6024, 4119, 2);
  INSERT INTO CONTIENE VALUES (7245, 6029, 4119, 1);
  INSERT INTO CONTIENE VALUES (7245, 6025, 4119, 1);
  INSERT INTO CONTIENE VALUES (7246, 6060, 4150, 3);
  INSERT INTO CONTIENE VALUES (7246, 6061, 4150, 4);
  INSERT INTO CONTIENE VALUES (7246, 6055, 4150, 3);
  INSERT INTO CONTIENE VALUES (7247, 6014, 4064, 1);
  INSERT INTO CONTIENE VALUES (7248, 6198, 4101, 1);
  INSERT INTO CONTIENE VALUES (7248, 6062, 4101, 3);
  INSERT INTO CONTIENE VALUES (7248, 6140, 4101, 2);
  INSERT INTO CONTIENE VALUES (7249, 6068, 4119, 4);
  INSERT INTO CONTIENE VALUES (7249, 6027, 4119, 1);
  INSERT INTO CONTIENE VALUES (7250, 6064, 4056, 3);
  INSERT INTO CONTIENE VALUES (7251, 6177, 4081, 3);
  INSERT INTO CONTIENE VALUES (7252, 6197, 4104, 2);
  INSERT INTO CONTIENE VALUES (7253, 6122, 4187, 1);
  INSERT INTO CONTIENE VALUES (7253, 6176, 4187, 3);
  INSERT INTO CONTIENE VALUES (7254, 6080, 4159, 4);
  INSERT INTO CONTIENE VALUES (7254, 6065, 4159, 2);
  INSERT INTO CONTIENE VALUES (7254, 6104, 4159, 3);
  INSERT INTO CONTIENE VALUES (7255, 6169, 4077, 4);
  COMMIT;
END;

--bloque 6
BEGIN
  INSERT INTO CONTIENE VALUES (7255, 6109, 4077, 2);
  INSERT INTO CONTIENE VALUES (7256, 6072, 4011, 3);
  INSERT INTO CONTIENE VALUES (7257, 6141, 4109, 1);
  INSERT INTO CONTIENE VALUES (7258, 6065, 4196, 2);
  INSERT INTO CONTIENE VALUES (7259, 6055, 4142, 1);
  INSERT INTO CONTIENE VALUES (7260, 6047, 4046, 1);
  INSERT INTO CONTIENE VALUES (7261, 6068, 4024, 4);
  INSERT INTO CONTIENE VALUES (7262, 6067, 4172, 3);
  INSERT INTO CONTIENE VALUES (7262, 6065, 4172, 2);
  INSERT INTO CONTIENE VALUES (7263, 6070, 4108, 3);
  INSERT INTO CONTIENE VALUES (7263, 6150, 4108, 2);
  INSERT INTO CONTIENE VALUES (7263, 6145, 4108, 4);
  INSERT INTO CONTIENE VALUES (7264, 6068, 4162, 2);
  INSERT INTO CONTIENE VALUES (7264, 6069, 4162, 2);
  INSERT INTO CONTIENE VALUES (7264, 6080, 4162, 2);
  INSERT INTO CONTIENE VALUES (7265, 6045, 4046, 4);
  INSERT INTO CONTIENE VALUES (7265, 6048, 4046, 2);
  INSERT INTO CONTIENE VALUES (7266, 6105, 4157, 3);
  INSERT INTO CONTIENE VALUES (7266, 6104, 4157, 2);
  INSERT INTO CONTIENE VALUES (7267, 6058, 4197, 4);
  INSERT INTO CONTIENE VALUES (7268, 6170, 4084, 1);
  INSERT INTO CONTIENE VALUES (7268, 6107, 4084, 2);
  INSERT INTO CONTIENE VALUES (7268, 6117, 4084, 3);
  INSERT INTO CONTIENE VALUES (7269, 6159, 4170, 4);
  INSERT INTO CONTIENE VALUES (7269, 6147, 4170, 4);
  INSERT INTO CONTIENE VALUES (7270, 6074, 4053, 1);
  INSERT INTO CONTIENE VALUES (7271, 6070, 4142, 1);
  INSERT INTO CONTIENE VALUES (7271, 6063, 4142, 2);
  INSERT INTO CONTIENE VALUES (7271, 6062, 4142, 2);
  INSERT INTO CONTIENE VALUES (7272, 6012, 4057, 2);
  INSERT INTO CONTIENE VALUES (7273, 6075, 4067, 3);
  INSERT INTO CONTIENE VALUES (7274, 6134, 4192, 1);
  INSERT INTO CONTIENE VALUES (7274, 6186, 4192, 1);
  INSERT INTO CONTIENE VALUES (7274, 6128, 4192, 3);
  INSERT INTO CONTIENE VALUES (7275, 6075, 4067, 3);
  INSERT INTO CONTIENE VALUES (7275, 6061, 4067, 4);
  INSERT INTO CONTIENE VALUES (7275, 6016, 4067, 4);
  INSERT INTO CONTIENE VALUES (7276, 6062, 4148, 4);
  INSERT INTO CONTIENE VALUES (7276, 6069, 4148, 4);
  INSERT INTO CONTIENE VALUES (7276, 6060, 4148, 4);
  INSERT INTO CONTIENE VALUES (7277, 6140, 4190, 2);
  INSERT INTO CONTIENE VALUES (7278, 6137, 4111, 1);
  INSERT INTO CONTIENE VALUES (7279, 6050, 4053, 4);
  INSERT INTO CONTIENE VALUES (7279, 6016, 4053, 2);
  INSERT INTO CONTIENE VALUES (7280, 6061, 4167, 3);
  INSERT INTO CONTIENE VALUES (7280, 6065, 4167, 3);
  INSERT INTO CONTIENE VALUES (7280, 6067, 4167, 2);
  INSERT INTO CONTIENE VALUES (7281, 6036, 4138, 4);
  INSERT INTO CONTIENE VALUES (7281, 6067, 4138, 1);
  INSERT INTO CONTIENE VALUES (7282, 6112, 4074, 1);
  INSERT INTO CONTIENE VALUES (7282, 6118, 4074, 1);
  INSERT INTO CONTIENE VALUES (7283, 6072, 4016, 1);
  INSERT INTO CONTIENE VALUES (7283, 6063, 4016, 2);
  INSERT INTO CONTIENE VALUES (7283, 6069, 4016, 1);
  INSERT INTO CONTIENE VALUES (7284, 6070, 4131, 1);
  INSERT INTO CONTIENE VALUES (7284, 6065, 4131, 2);
  INSERT INTO CONTIENE VALUES (7284, 6067, 4131, 3);
  INSERT INTO CONTIENE VALUES (7285, 6120, 4086, 2);
  INSERT INTO CONTIENE VALUES (7285, 6111, 4086, 2);
  INSERT INTO CONTIENE VALUES (7286, 6065, 4148, 4);
  INSERT INTO CONTIENE VALUES (7287, 6066, 4005, 3);
  INSERT INTO CONTIENE VALUES (7288, 6105, 4159, 3);
  INSERT INTO CONTIENE VALUES (7288, 6081, 4159, 3);
  INSERT INTO CONTIENE VALUES (7289, 6050, 4184, 2);
  INSERT INTO CONTIENE VALUES (7289, 6065, 4184, 3);
  INSERT INTO CONTIENE VALUES (7289, 6011, 4184, 3);
  INSERT INTO CONTIENE VALUES (7290, 6117, 4083, 1);
  INSERT INTO CONTIENE VALUES (7290, 6168, 4083, 2);
  INSERT INTO CONTIENE VALUES (7291, 6065, 4066, 3);
  INSERT INTO CONTIENE VALUES (7291, 6012, 4066, 2);
  INSERT INTO CONTIENE VALUES (7292, 6108, 4074, 4);
  INSERT INTO CONTIENE VALUES (7292, 6114, 4074, 3);
  INSERT INTO CONTIENE VALUES (7293, 6138, 4109, 4);
  INSERT INTO CONTIENE VALUES (7293, 6061, 4109, 4);
  INSERT INTO CONTIENE VALUES (7293, 6142, 4109, 1);
  INSERT INTO CONTIENE VALUES (7294, 6061, 4158, 3);
  INSERT INTO CONTIENE VALUES (7294, 6102, 4158, 4);
  INSERT INTO CONTIENE VALUES (7294, 6062, 4158, 1);
  INSERT INTO CONTIENE VALUES (7295, 6173, 4074, 4);
  INSERT INTO CONTIENE VALUES (7295, 6177, 4074, 3);
  INSERT INTO CONTIENE VALUES (7296, 6061, 4173, 3);
  INSERT INTO CONTIENE VALUES (7297, 6008, 4018, 3);
  INSERT INTO CONTIENE VALUES (7297, 6009, 4018, 1);
  INSERT INTO CONTIENE VALUES (7297, 6067, 4018, 4);
  INSERT INTO CONTIENE VALUES (7298, 6061, 4171, 4);
  INSERT INTO CONTIENE VALUES (7299, 6002, 4181, 2);
  INSERT INTO CONTIENE VALUES (7300, 6050, 4062, 2);
  INSERT INTO CONTIENE VALUES (7300, 6065, 4062, 2);
  INSERT INTO CONTIENE VALUES (7300, 6012, 4062, 1);
  COMMIT;
END;

--bloque 7
BEGIN
  INSERT INTO CONTIENE VALUES (7295, 6059, 4153, 3);
  INSERT INTO CONTIENE VALUES (7295, 6056, 4153, 2);
  INSERT INTO CONTIENE VALUES (7296, 6116, 4087, 4);
  INSERT INTO CONTIENE VALUES (7296, 6177, 4087, 1);
  INSERT INTO CONTIENE VALUES (7296, 6175, 4087, 4);
  INSERT INTO CONTIENE VALUES (7297, 6197, 4192, 4);
  INSERT INTO CONTIENE VALUES (7297, 6137, 4192, 4);
  INSERT INTO CONTIENE VALUES (7297, 6184, 4192, 2);
  INSERT INTO CONTIENE VALUES (7298, 6006, 4015, 3);
  INSERT INTO CONTIENE VALUES (7299, 6127, 4099, 4);
  INSERT INTO CONTIENE VALUES (7299, 6186, 4099, 2);
  INSERT INTO CONTIENE VALUES (7300, 6046, 4048, 1);
  INSERT INTO CONTIENE VALUES (7300, 6060, 4048, 1);
  INSERT INTO CONTIENE VALUES (7300, 6059, 4048, 1);
  INSERT INTO CONTIENE VALUES (7301, 6146, 4177, 1);
  INSERT INTO CONTIENE VALUES (7301, 6163, 4177, 2);
  INSERT INTO CONTIENE VALUES (7301, 6151, 4177, 3);
  INSERT INTO CONTIENE VALUES (7302, 6038, 4138, 4);
  INSERT INTO CONTIENE VALUES (7303, 6186, 4089, 1);
  INSERT INTO CONTIENE VALUES (7303, 6195, 4089, 2);
  INSERT INTO CONTIENE VALUES (7304, 6012, 4061, 3);
  INSERT INTO CONTIENE VALUES (7304, 6062, 4061, 1);
  INSERT INTO CONTIENE VALUES (7305, 6033, 4138, 1);
  INSERT INTO CONTIENE VALUES (7305, 6031, 4138, 3);
  INSERT INTO CONTIENE VALUES (7305, 6068, 4138, 2);
  INSERT INTO CONTIENE VALUES (7306, 6065, 4194, 4);
  INSERT INTO CONTIENE VALUES (7306, 6067, 4194, 1);
  INSERT INTO CONTIENE VALUES (7306, 6064, 4194, 1);
  INSERT INTO CONTIENE VALUES (7307, 6008, 4017, 2);
  INSERT INTO CONTIENE VALUES (7308, 6140, 4100, 2);
  INSERT INTO CONTIENE VALUES (7309, 6033, 4133, 3);
  INSERT INTO CONTIENE VALUES (7310, 6103, 4014, 4);
  INSERT INTO CONTIENE VALUES (7310, 6002, 4014, 4);
  INSERT INTO CONTIENE VALUES (7310, 6005, 4014, 3);
  INSERT INTO CONTIENE VALUES (7311, 6095, 4034, 4);
  INSERT INTO CONTIENE VALUES (7312, 6062, 4061, 2);
  INSERT INTO CONTIENE VALUES (7312, 6075, 4061, 4);
  INSERT INTO CONTIENE VALUES (7312, 6070, 4061, 3);
  INSERT INTO CONTIENE VALUES (7313, 6091, 4035, 1);
  INSERT INTO CONTIENE VALUES (7313, 6063, 4035, 4);
  INSERT INTO CONTIENE VALUES (7314, 6002, 4022, 3);
  INSERT INTO CONTIENE VALUES (7314, 6004, 4022, 3);
  INSERT INTO CONTIENE VALUES (7314, 6069, 4022, 4);
  INSERT INTO CONTIENE VALUES (7315, 6005, 4020, 2);
  INSERT INTO CONTIENE VALUES (7315, 6071, 4020, 4);
  INSERT INTO CONTIENE VALUES (7315, 6061, 4020, 4);
  INSERT INTO CONTIENE VALUES (7316, 6074, 4185, 3);
  INSERT INTO CONTIENE VALUES (7316, 6076, 4185, 3);
  INSERT INTO CONTIENE VALUES (7316, 6012, 4185, 3);
  INSERT INTO CONTIENE VALUES (7317, 6028, 4124, 3);
  INSERT INTO CONTIENE VALUES (7317, 6069, 4124, 4);
  INSERT INTO CONTIENE VALUES (7317, 6066, 4124, 1);
  INSERT INTO CONTIENE VALUES (7318, 6109, 4081, 1);
  INSERT INTO CONTIENE VALUES (7318, 6106, 4081, 2);
  INSERT INTO CONTIENE VALUES (7319, 6061, 4142, 1);
  INSERT INTO CONTIENE VALUES (7319, 6069, 4142, 4);
  INSERT INTO CONTIENE VALUES (7319, 6064, 4142, 2);
  INSERT INTO CONTIENE VALUES (7320, 6169, 4086, 4);
  INSERT INTO CONTIENE VALUES (7320, 6166, 4086, 1);
  INSERT INTO CONTIENE VALUES (7321, 6103, 4024, 2);
  INSERT INTO CONTIENE VALUES (7321, 6004, 4024, 3);
  INSERT INTO CONTIENE VALUES (7322, 6174, 4072, 1);
  INSERT INTO CONTIENE VALUES (7323, 6050, 4039, 2);
  INSERT INTO CONTIENE VALUES (7323, 6041, 4039, 4);
  INSERT INTO CONTIENE VALUES (7323, 6070, 4039, 4);
  INSERT INTO CONTIENE VALUES (7324, 6013, 4055, 3);
  INSERT INTO CONTIENE VALUES (7324, 6061, 4055, 3);
  INSERT INTO CONTIENE VALUES (7325, 6063, 4195, 3);
  INSERT INTO CONTIENE VALUES (7326, 6147, 4173, 4);
  INSERT INTO CONTIENE VALUES (7326, 6149, 4173, 1);
  INSERT INTO CONTIENE VALUES (7326, 6153, 4173, 2);
  INSERT INTO CONTIENE VALUES (7327, 6132, 4098, 1);
  INSERT INTO CONTIENE VALUES (7328, 6151, 4110, 1);
  INSERT INTO CONTIENE VALUES (7328, 6162, 4110, 1);
  INSERT INTO CONTIENE VALUES (7329, 6057, 4141, 3);
  INSERT INTO CONTIENE VALUES (7329, 6056, 4141, 3);
  INSERT INTO CONTIENE VALUES (7329, 6061, 4141, 3);
  INSERT INTO CONTIENE VALUES (7330, 6120, 4087, 1);
  INSERT INTO CONTIENE VALUES (7330, 6123, 4087, 1);
  INSERT INTO CONTIENE VALUES (7330, 6111, 4087, 4);
  INSERT INTO CONTIENE VALUES (7331, 6067, 4013, 3);
  INSERT INTO CONTIENE VALUES (7331, 6009, 4013, 4);
  INSERT INTO CONTIENE VALUES (7332, 6115, 4087, 4);
  INSERT INTO CONTIENE VALUES (7333, 6055, 4199, 2);
  INSERT INTO CONTIENE VALUES (7334, 6113, 4088, 4);
  INSERT INTO CONTIENE VALUES (7334, 6106, 4088, 3);
  INSERT INTO CONTIENE VALUES (7334, 6120, 4088, 3);
  INSERT INTO CONTIENE VALUES (7335, 6139, 4094, 2);
  INSERT INTO CONTIENE VALUES (7335, 6137, 4094, 1);
  INSERT INTO CONTIENE VALUES (7336, 6101, 4200, 4);
  INSERT INTO CONTIENE VALUES (7336, 6080, 4200, 1);
  INSERT INTO CONTIENE VALUES (7336, 6063, 4200, 2);
  INSERT INTO CONTIENE VALUES (7337, 6063, 4008, 2);
  INSERT INTO CONTIENE VALUES (7337, 6065, 4008, 4);
  INSERT INTO CONTIENE VALUES (7337, 6067, 4008, 2);
  INSERT INTO CONTIENE VALUES (7338, 6189, 4192, 1);
  INSERT INTO CONTIENE VALUES (7339, 6067, 4155, 2);
  INSERT INTO CONTIENE VALUES (7340, 6149, 4172, 4);
  INSERT INTO CONTIENE VALUES (7341, 6058, 4152, 2);
  INSERT INTO CONTIENE VALUES (7341, 6057, 4152, 1);
  INSERT INTO CONTIENE VALUES (7341, 6066, 4152, 1);
  INSERT INTO CONTIENE VALUES (7342, 6101, 4164, 1);
  INSERT INTO CONTIENE VALUES (7342, 6065, 4164, 4);
  INSERT INTO CONTIENE VALUES (7343, 6196, 4094, 1);
  INSERT INTO CONTIENE VALUES (7343, 6130, 4094, 1);
  INSERT INTO CONTIENE VALUES (7344, 6008, 4005, 4);
  INSERT INTO CONTIENE VALUES (7344, 6004, 4005, 3);
  INSERT INTO CONTIENE VALUES (7344, 6069, 4005, 1);
  INSERT INTO CONTIENE VALUES (7345, 6165, 4177, 3);
  INSERT INTO CONTIENE VALUES (7345, 6066, 4177, 4);
  INSERT INTO CONTIENE VALUES (7346, 6071, 4005, 4);
  INSERT INTO CONTIENE VALUES (7346, 6072, 4005, 3);
  INSERT INTO CONTIENE VALUES (7346, 6068, 4005, 3);
  INSERT INTO CONTIENE VALUES (7347, 6001, 4008, 1);
  INSERT INTO CONTIENE VALUES (7348, 6021, 4114, 4);
  INSERT INTO CONTIENE VALUES (7349, 6104, 4167, 4);
  INSERT INTO CONTIENE VALUES (7349, 6069, 4167, 4);
  INSERT INTO CONTIENE VALUES (7349, 6063, 4167, 3);
  INSERT INTO CONTIENE VALUES (7350, 6105, 4158, 3);
  INSERT INTO CONTIENE VALUES (7350, 6101, 4158, 3);
  INSERT INTO CONTIENE VALUES (7350, 6068, 4158, 3);
  INSERT INTO CONTIENE VALUES (7351, 6111, 4082, 2);
  INSERT INTO CONTIENE VALUES (7351, 6118, 4082, 1);
  INSERT INTO CONTIENE VALUES (7351, 6106, 4082, 2);
  INSERT INTO CONTIENE VALUES (7352, 6172, 4082, 1);
  COMMIT;
END;


--bloque 8
BEGIN
  INSERT INTO CONTIENE VALUES (7352, 6124, 4082, 3);
  INSERT INTO CONTIENE VALUES (7352, 6111, 4082, 3);
  INSERT INTO CONTIENE VALUES (7353, 6069, 4027, 3);
  INSERT INTO CONTIENE VALUES (7353, 6007, 4027, 3);
  INSERT INTO CONTIENE VALUES (7353, 6066, 4027, 1);
  INSERT INTO CONTIENE VALUES (7354, 6061, 4067, 3);
  INSERT INTO CONTIENE VALUES (7354, 6013, 4067, 2);
  INSERT INTO CONTIENE VALUES (7355, 6169, 4189, 4);
  INSERT INTO CONTIENE VALUES (7355, 6168, 4189, 1);
  INSERT INTO CONTIENE VALUES (7356, 6066, 4160, 2);
  INSERT INTO CONTIENE VALUES (7356, 6063, 4160, 3);
  INSERT INTO CONTIENE VALUES (7356, 6062, 4160, 4);
  INSERT INTO CONTIENE VALUES (7357, 6157, 4178, 1);
  INSERT INTO CONTIENE VALUES (7358, 6070, 4122, 3);
  INSERT INTO CONTIENE VALUES (7359, 6061, 4161, 2);
  INSERT INTO CONTIENE VALUES (7359, 6104, 4161, 3);
  INSERT INTO CONTIENE VALUES (7360, 6170, 4085, 3);
  INSERT INTO CONTIENE VALUES (7361, 6062, 4190, 2);
  INSERT INTO CONTIENE VALUES (7361, 6064, 4190, 3);
  INSERT INTO CONTIENE VALUES (7361, 6138, 4190, 2);
  INSERT INTO CONTIENE VALUES (7362, 6070, 4096, 3);
  INSERT INTO CONTIENE VALUES (7363, 6060, 4154, 3);
  INSERT INTO CONTIENE VALUES (7363, 6058, 4154, 1);
  INSERT INTO CONTIENE VALUES (7364, 6024, 4124, 3);
  INSERT INTO CONTIENE VALUES (7365, 6006, 4015, 4);
  INSERT INTO CONTIENE VALUES (7366, 6024, 4126, 2);
  INSERT INTO CONTIENE VALUES (7367, 6179, 4097, 3);
  INSERT INTO CONTIENE VALUES (7367, 6187, 4097, 3);
  INSERT INTO CONTIENE VALUES (7368, 6005, 4019, 4);
  INSERT INTO CONTIENE VALUES (7368, 6067, 4019, 4);
  INSERT INTO CONTIENE VALUES (7369, 6066, 4149, 4);
  INSERT INTO CONTIENE VALUES (7369, 6058, 4149, 3);
  INSERT INTO CONTIENE VALUES (7370, 6023, 4123, 4);
  INSERT INTO CONTIENE VALUES (7370, 6063, 4123, 3);
  INSERT INTO CONTIENE VALUES (7371, 6097, 4033, 4);
  INSERT INTO CONTIENE VALUES (7372, 6040, 4127, 3);
  INSERT INTO CONTIENE VALUES (7372, 6031, 4127, 4);
  INSERT INTO CONTIENE VALUES (7372, 6065, 4127, 1);
  INSERT INTO CONTIENE VALUES (7373, 6179, 4097, 3);
  INSERT INTO CONTIENE VALUES (7373, 6128, 4097, 1);
  INSERT INTO CONTIENE VALUES (7374, 6009, 4007, 1);
  INSERT INTO CONTIENE VALUES (7375, 6065, 4063, 1);
  INSERT INTO CONTIENE VALUES (7375, 6013, 4063, 2);
  INSERT INTO CONTIENE VALUES (7376, 6032, 4130, 1);
  INSERT INTO CONTIENE VALUES (7376, 6037, 4130, 4);
  INSERT INTO CONTIENE VALUES (7376, 6065, 4130, 3);
  INSERT INTO CONTIENE VALUES (7377, 6092, 4031, 4);
  INSERT INTO CONTIENE VALUES (7378, 6063, 4020, 2);
  INSERT INTO CONTIENE VALUES (7379, 6071, 4009, 3);
  INSERT INTO CONTIENE VALUES (7379, 6066, 4009, 1);
  INSERT INTO CONTIENE VALUES (7379, 6061, 4009, 2);
  INSERT INTO CONTIENE VALUES (7380, 6070, 4019, 1);
  INSERT INTO CONTIENE VALUES (7380, 6003, 4019, 1);
  INSERT INTO CONTIENE VALUES (7381, 6165, 4172, 3);
  INSERT INTO CONTIENE VALUES (7382, 6066, 4102, 2);
  INSERT INTO CONTIENE VALUES (7382, 6130, 4102, 1);
  INSERT INTO CONTIENE VALUES (7382, 6062, 4102, 3);
  INSERT INTO CONTIENE VALUES (7383, 6015, 4061, 2);
  INSERT INTO CONTIENE VALUES (7384, 6065, 4020, 1);
  INSERT INTO CONTIENE VALUES (7384, 6008, 4020, 4);
  INSERT INTO CONTIENE VALUES (7385, 6065, 4178, 2);
  INSERT INTO CONTIENE VALUES (7385, 6159, 4178, 4);
  INSERT INTO CONTIENE VALUES (7386, 6200, 4096, 3);
  INSERT INTO CONTIENE VALUES (7386, 6129, 4096, 2);
  INSERT INTO CONTIENE VALUES (7387, 6044, 4048, 4);
  INSERT INTO CONTIENE VALUES (7387, 6065, 4048, 3);
  INSERT INTO CONTIENE VALUES (7388, 6103, 4015, 3);
  INSERT INTO CONTIENE VALUES (7388, 6072, 4015, 3);
  INSERT INTO CONTIENE VALUES (7389, 6036, 4131, 1);
  INSERT INTO CONTIENE VALUES (7389, 6038, 4131, 4);
  INSERT INTO CONTIENE VALUES (7390, 6103, 4036, 2);
  INSERT INTO CONTIENE VALUES (7391, 6061, 4123, 2);
  INSERT INTO CONTIENE VALUES (7392, 6110, 4088, 3);
  INSERT INTO CONTIENE VALUES (7392, 6125, 4088, 2);
  INSERT INTO CONTIENE VALUES (7393, 6124, 4087, 3);
  INSERT INTO CONTIENE VALUES (7393, 6172, 4087, 1);
  INSERT INTO CONTIENE VALUES (7394, 6058, 4147, 1);
  INSERT INTO CONTIENE VALUES (7394, 6067, 4147, 2);
  INSERT INTO CONTIENE VALUES (7394, 6070, 4147, 2);
  INSERT INTO CONTIENE VALUES (7395, 6075, 4185, 1);
  INSERT INTO CONTIENE VALUES (7396, 6161, 4179, 4);
  INSERT INTO CONTIENE VALUES (7396, 6146, 4179, 3);
  INSERT INTO CONTIENE VALUES (7396, 6164, 4179, 2);
  INSERT INTO CONTIENE VALUES (7397, 6110, 4186, 3);
  INSERT INTO CONTIENE VALUES (7397, 6169, 4186, 2);
  INSERT INTO CONTIENE VALUES (7397, 6115, 4186, 3);
  INSERT INTO CONTIENE VALUES (7398, 6001, 4001, 3);
  INSERT INTO CONTIENE VALUES (7398, 6069, 4001, 3);
  INSERT INTO CONTIENE VALUES (7398, 6008, 4001, 2);
  INSERT INTO CONTIENE VALUES (7399, 6006, 4012, 2);
  INSERT INTO CONTIENE VALUES (7399, 6069, 4012, 2);
  INSERT INTO CONTIENE VALUES (7400, 6064, 4031, 4);
  INSERT INTO CONTIENE VALUES (7400, 6096, 4031, 3);
  INSERT INTO CONTIENE VALUES (7401, 6065, 4166, 2);
  INSERT INTO CONTIENE VALUES (7402, 6011, 4184, 2);
  INSERT INTO CONTIENE VALUES (7402, 6016, 4184, 4);
  INSERT INTO CONTIENE VALUES (7402, 6014, 4184, 4);
  INSERT INTO CONTIENE VALUES (7403, 6065, 4008, 1);
  INSERT INTO CONTIENE VALUES (7403, 6002, 4008, 3);
  INSERT INTO CONTIENE VALUES (7404, 6068, 4144, 3);
  INSERT INTO CONTIENE VALUES (7405, 6059, 4183, 2);
  INSERT INTO CONTIENE VALUES (7405, 6043, 4183, 2);
  INSERT INTO CONTIENE VALUES (7406, 6061, 4163, 3);
  INSERT INTO CONTIENE VALUES (7406, 6080, 4163, 1);
  INSERT INTO CONTIENE VALUES (7407, 6066, 4199, 3);
  INSERT INTO CONTIENE VALUES (7408, 6063, 4004, 2);
  INSERT INTO CONTIENE VALUES (7408, 6007, 4004, 4);
  INSERT INTO CONTIENE VALUES (7408, 6008, 4004, 2);
  INSERT INTO CONTIENE VALUES (7409, 6015, 4069, 3);
  INSERT INTO CONTIENE VALUES (7409, 6064, 4069, 1);
  INSERT INTO CONTIENE VALUES (7410, 6013, 4184, 1);
  INSERT INTO CONTIENE VALUES (7410, 6068, 4184, 2);
  INSERT INTO CONTIENE VALUES (7411, 6001, 4004, 3);
  INSERT INTO CONTIENE VALUES (7411, 6068, 4004, 2);
  INSERT INTO CONTIENE VALUES (7412, 6197, 4099, 2);
  INSERT INTO CONTIENE VALUES (7413, 6070, 4036, 1);
  INSERT INTO CONTIENE VALUES (7413, 6102, 4036, 3);
  INSERT INTO CONTIENE VALUES (7413, 6093, 4036, 1);
  INSERT INTO CONTIENE VALUES (7414, 6100, 4031, 2);
  INSERT INTO CONTIENE VALUES (7414, 6017, 4031, 4);
  INSERT INTO CONTIENE VALUES (7415, 6070, 4166, 3);
  INSERT INTO CONTIENE VALUES (7415, 6065, 4166, 4);
  INSERT INTO CONTIENE VALUES (7415, 6061, 4166, 3);
  INSERT INTO CONTIENE VALUES (7416, 6059, 4152, 3);
  INSERT INTO CONTIENE VALUES (7417, 6176, 4071, 1);
  INSERT INTO CONTIENE VALUES (7417, 6110, 4071, 4);
  INSERT INTO CONTIENE VALUES (7417, 6108, 4071, 1);
  INSERT INTO CONTIENE VALUES (7418, 6011, 4053, 3);
  INSERT INTO CONTIENE VALUES (7418, 6062, 4053, 3);
  INSERT INTO CONTIENE VALUES (7418, 6016, 4053, 4);
  INSERT INTO CONTIENE VALUES (7419, 6047, 4048, 1);
  INSERT INTO CONTIENE VALUES (7420, 6080, 4035, 1);
  INSERT INTO CONTIENE VALUES (7420, 6100, 4035, 2);
  INSERT INTO CONTIENE VALUES (7420, 6067, 4035, 2);
  INSERT INTO CONTIENE VALUES (7421, 6090, 4034, 2);
  INSERT INTO CONTIENE VALUES (7422, 6082, 4159, 3);
  INSERT INTO CONTIENE VALUES (7423, 6067, 4009, 4);
  INSERT INTO CONTIENE VALUES (7424, 6173, 4186, 2);
  INSERT INTO CONTIENE VALUES (7424, 6112, 4186, 3);
  INSERT INTO CONTIENE VALUES (7424, 6167, 4186, 2);
  INSERT INTO CONTIENE VALUES (7425, 6064, 4115, 4);
  INSERT INTO CONTIENE VALUES (7426, 6054, 4140, 1);
  INSERT INTO CONTIENE VALUES (7427, 6157, 4179, 4);
  INSERT INTO CONTIENE VALUES (7427, 6065, 4179, 1);
  INSERT INTO CONTIENE VALUES (7428, 6012, 4065, 1);
  INSERT INTO CONTIENE VALUES (7429, 6186, 4193, 2);
  INSERT INTO CONTIENE VALUES (7429, 6189, 4193, 2);
  INSERT INTO CONTIENE VALUES (7430, 6035, 4129, 4);
  INSERT INTO CONTIENE VALUES (7431, 6070, 4182, 1);
  INSERT INTO CONTIENE VALUES (7431, 6072, 4182, 3);
  INSERT INTO CONTIENE VALUES (7431, 6063, 4182, 4);
  INSERT INTO CONTIENE VALUES (7432, 6068, 4055, 3);
  INSERT INTO CONTIENE VALUES (7433, 6064, 4034, 3);
  INSERT INTO CONTIENE VALUES (7434, 6188, 4190, 1);
  INSERT INTO CONTIENE VALUES (7434, 6062, 4190, 1);
  INSERT INTO CONTIENE VALUES (7435, 6066, 4034, 4);
  INSERT INTO CONTIENE VALUES (7435, 6103, 4034, 4);
  INSERT INTO CONTIENE VALUES (7436, 6021, 4119, 4);
  INSERT INTO CONTIENE VALUES (7437, 6062, 4057, 4);
  INSERT INTO CONTIENE VALUES (7438, 6059, 4144, 1);
  INSERT INTO CONTIENE VALUES (7439, 6036, 4130, 2);
  INSERT INTO CONTIENE VALUES (7440, 6066, 4152, 4);
  INSERT INTO CONTIENE VALUES (7440, 6055, 4152, 2);
  INSERT INTO CONTIENE VALUES (7440, 6067, 4152, 2);
  INSERT INTO CONTIENE VALUES (7441, 6109, 4083, 4);
  INSERT INTO CONTIENE VALUES (7442, 6067, 4200, 2);
  INSERT INTO CONTIENE VALUES (7442, 6062, 4200, 1);
  INSERT INTO CONTIENE VALUES (7442, 6080, 4200, 2);
  INSERT INTO CONTIENE VALUES (7443, 6050, 4039, 1);
  INSERT INTO CONTIENE VALUES (7444, 6026, 4115, 1);
  INSERT INTO CONTIENE VALUES (7445, 6015, 4056, 2);
  INSERT INTO CONTIENE VALUES (7445, 6011, 4056, 4);
  INSERT INTO CONTIENE VALUES (7446, 6062, 4182, 3);
  INSERT INTO CONTIENE VALUES (7446, 6061, 4182, 3);
  INSERT INTO CONTIENE VALUES (7446, 6063, 4182, 4);
  INSERT INTO CONTIENE VALUES (7447, 6076, 4041, 4);
  INSERT INTO CONTIENE VALUES (7448, 6061, 4140, 2);
  INSERT INTO CONTIENE VALUES (7449, 6044, 4040, 3);
  INSERT INTO CONTIENE VALUES (7449, 6042, 4040, 1);
  INSERT INTO CONTIENE VALUES (7449, 6041, 4040, 1);
  INSERT INTO CONTIENE VALUES (7450, 6067, 4129, 2);
  INSERT INTO CONTIENE VALUES (7450, 6068, 4129, 4);
  INSERT INTO CONTIENE VALUES (7450, 6069, 4129, 3);
  INSERT INTO CONTIENE VALUES (7451, 6094, 4038, 1);
  INSERT INTO CONTIENE VALUES (7451, 6090, 4038, 2);
  INSERT INTO CONTIENE VALUES (7452, 6067, 4164, 3);
  INSERT INTO CONTIENE VALUES (7452, 6070, 4164, 4);
  INSERT INTO CONTIENE VALUES (7453, 6147, 4176, 1);
  INSERT INTO CONTIENE VALUES (7454, 6052, 4198, 3);
  INSERT INTO CONTIENE VALUES (7454, 6054, 4198, 1);
  INSERT INTO CONTIENE VALUES (7454, 6063, 4198, 2);
  INSERT INTO CONTIENE VALUES (7455, 6065, 4020, 1);
  INSERT INTO CONTIENE VALUES (7455, 6071, 4020, 3);
  INSERT INTO CONTIENE VALUES (7455, 6072, 4020, 2);
  INSERT INTO CONTIENE VALUES (7456, 6189, 4192, 3);
  INSERT INTO CONTIENE VALUES (7456, 6128, 4192, 4);
  INSERT INTO CONTIENE VALUES (7457, 6160, 4173, 4);
  INSERT INTO CONTIENE VALUES (7458, 6061, 4055, 4);
  INSERT INTO CONTIENE VALUES (7458, 6063, 4055, 1);
  INSERT INTO CONTIENE VALUES (7459, 6055, 4146, 1);
  COMMIT;
END;

--bloque 9
BEGIN
  INSERT INTO CONTIENE VALUES (7401, 6065, 4166, 2);
  INSERT INTO CONTIENE VALUES (7402, 6011, 4184, 2);
  INSERT INTO CONTIENE VALUES (7402, 6016, 4184, 4);
  INSERT INTO CONTIENE VALUES (7402, 6014, 4184, 4);
  INSERT INTO CONTIENE VALUES (7403, 6065, 4008, 1);
  INSERT INTO CONTIENE VALUES (7403, 6002, 4008, 3);
  INSERT INTO CONTIENE VALUES (7404, 6068, 4144, 3);
  INSERT INTO CONTIENE VALUES (7405, 6059, 4183, 2);
  INSERT INTO CONTIENE VALUES (7405, 6043, 4183, 2);
  INSERT INTO CONTIENE VALUES (7406, 6061, 4163, 3);
  INSERT INTO CONTIENE VALUES (7406, 6080, 4163, 1);
  INSERT INTO CONTIENE VALUES (7407, 6066, 4199, 3);
  INSERT INTO CONTIENE VALUES (7408, 6063, 4004, 2);
  INSERT INTO CONTIENE VALUES (7408, 6007, 4004, 4);
  INSERT INTO CONTIENE VALUES (7408, 6008, 4004, 2);
  INSERT INTO CONTIENE VALUES (7409, 6015, 4069, 3);
  INSERT INTO CONTIENE VALUES (7409, 6064, 4069, 1);
  INSERT INTO CONTIENE VALUES (7410, 6013, 4184, 1);
  INSERT INTO CONTIENE VALUES (7410, 6068, 4184, 2);
  INSERT INTO CONTIENE VALUES (7411, 6001, 4004, 3);
  INSERT INTO CONTIENE VALUES (7411, 6068, 4004, 2);
  INSERT INTO CONTIENE VALUES (7412, 6197, 4099, 2);
  INSERT INTO CONTIENE VALUES (7413, 6070, 4036, 1);
  INSERT INTO CONTIENE VALUES (7413, 6102, 4036, 3);
  INSERT INTO CONTIENE VALUES (7413, 6093, 4036, 1);
  INSERT INTO CONTIENE VALUES (7414, 6100, 4031, 2);
  INSERT INTO CONTIENE VALUES (7414, 6017, 4031, 4);
  INSERT INTO CONTIENE VALUES (7415, 6070, 4166, 3);
  INSERT INTO CONTIENE VALUES (7415, 6065, 4166, 4);
  INSERT INTO CONTIENE VALUES (7415, 6061, 4166, 3);
  INSERT INTO CONTIENE VALUES (7416, 6059, 4152, 3);
  INSERT INTO CONTIENE VALUES (7417, 6176, 4071, 1);
  INSERT INTO CONTIENE VALUES (7417, 6110, 4071, 4);
  INSERT INTO CONTIENE VALUES (7417, 6108, 4071, 1);
  INSERT INTO CONTIENE VALUES (7418, 6011, 4053, 3);
  INSERT INTO CONTIENE VALUES (7418, 6062, 4053, 3);
  INSERT INTO CONTIENE VALUES (7418, 6016, 4053, 4);
  INSERT INTO CONTIENE VALUES (7419, 6047, 4048, 1);
  INSERT INTO CONTIENE VALUES (7420, 6080, 4035, 1);
  INSERT INTO CONTIENE VALUES (7420, 6100, 4035, 2);
  INSERT INTO CONTIENE VALUES (7420, 6067, 4035, 2);
  INSERT INTO CONTIENE VALUES (7421, 6090, 4034, 2);
  INSERT INTO CONTIENE VALUES (7422, 6082, 4159, 3);
  INSERT INTO CONTIENE VALUES (7423, 6067, 4009, 4);
  INSERT INTO CONTIENE VALUES (7424, 6173, 4186, 2);
  INSERT INTO CONTIENE VALUES (7424, 6112, 4186, 3);
  INSERT INTO CONTIENE VALUES (7424, 6167, 4186, 2);
  INSERT INTO CONTIENE VALUES (7425, 6064, 4115, 4);
  INSERT INTO CONTIENE VALUES (7426, 6054, 4140, 1);
  INSERT INTO CONTIENE VALUES (7427, 6157, 4179, 4);
  INSERT INTO CONTIENE VALUES (7427, 6065, 4179, 1);
  INSERT INTO CONTIENE VALUES (7428, 6012, 4065, 1);
  INSERT INTO CONTIENE VALUES (7429, 6186, 4193, 2);
  INSERT INTO CONTIENE VALUES (7429, 6189, 4193, 2);
  INSERT INTO CONTIENE VALUES (7430, 6035, 4129, 4);
  INSERT INTO CONTIENE VALUES (7431, 6070, 4182, 1);
  INSERT INTO CONTIENE VALUES (7431, 6072, 4182, 3);
  INSERT INTO CONTIENE VALUES (7431, 6063, 4182, 4);
  INSERT INTO CONTIENE VALUES (7432, 6068, 4055, 3);
  INSERT INTO CONTIENE VALUES (7433, 6064, 4034, 3);
  INSERT INTO CONTIENE VALUES (7434, 6188, 4190, 1);
  INSERT INTO CONTIENE VALUES (7434, 6062, 4190, 1);
  INSERT INTO CONTIENE VALUES (7435, 6066, 4034, 4);
  INSERT INTO CONTIENE VALUES (7435, 6103, 4034, 4);
  INSERT INTO CONTIENE VALUES (7436, 6021, 4119, 4);
  INSERT INTO CONTIENE VALUES (7437, 6062, 4057, 4);
  INSERT INTO CONTIENE VALUES (7438, 6059, 4144, 1);
  INSERT INTO CONTIENE VALUES (7439, 6036, 4130, 2);
  INSERT INTO CONTIENE VALUES (7440, 6066, 4152, 4);
  INSERT INTO CONTIENE VALUES (7440, 6055, 4152, 2);
  INSERT INTO CONTIENE VALUES (7440, 6067, 4152, 2);
  INSERT INTO CONTIENE VALUES (7441, 6109, 4083, 4);
  INSERT INTO CONTIENE VALUES (7442, 6067, 4200, 2);
  INSERT INTO CONTIENE VALUES (7442, 6062, 4200, 1);
  INSERT INTO CONTIENE VALUES (7442, 6080, 4200, 2);
  INSERT INTO CONTIENE VALUES (7443, 6050, 4039, 1);
  INSERT INTO CONTIENE VALUES (7444, 6026, 4115, 1);
  INSERT INTO CONTIENE VALUES (7445, 6015, 4056, 2);
  INSERT INTO CONTIENE VALUES (7445, 6011, 4056, 4);
  INSERT INTO CONTIENE VALUES (7446, 6062, 4182, 3);
  INSERT INTO CONTIENE VALUES (7446, 6061, 4182, 3);
  INSERT INTO CONTIENE VALUES (7446, 6063, 4182, 4);
  INSERT INTO CONTIENE VALUES (7447, 6076, 4041, 4);
  INSERT INTO CONTIENE VALUES (7448, 6061, 4140, 2);
  INSERT INTO CONTIENE VALUES (7449, 6044, 4040, 3);
  INSERT INTO CONTIENE VALUES (7449, 6042, 4040, 1);
  INSERT INTO CONTIENE VALUES (7449, 6041, 4040, 1);
  INSERT INTO CONTIENE VALUES (7450, 6067, 4129, 2);
  INSERT INTO CONTIENE VALUES (7450, 6068, 4129, 4);
  INSERT INTO CONTIENE VALUES (7450, 6069, 4129, 3);
  INSERT INTO CONTIENE VALUES (7451, 6094, 4038, 1);
  INSERT INTO CONTIENE VALUES (7451, 6090, 4038, 2);
  INSERT INTO CONTIENE VALUES (7452, 6067, 4164, 3);
  INSERT INTO CONTIENE VALUES (7452, 6070, 4164, 4);
  INSERT INTO CONTIENE VALUES (7453, 6147, 4176, 1);
  INSERT INTO CONTIENE VALUES (7454, 6052, 4198, 3);
  INSERT INTO CONTIENE VALUES (7454, 6054, 4198, 1);
  INSERT INTO CONTIENE VALUES (7454, 6063, 4198, 2);
  INSERT INTO CONTIENE VALUES (7455, 6065, 4020, 1);
  INSERT INTO CONTIENE VALUES (7455, 6071, 4020, 3);
  INSERT INTO CONTIENE VALUES (7455, 6072, 4020, 2);
  INSERT INTO CONTIENE VALUES (7456, 6189, 4192, 3);
  INSERT INTO CONTIENE VALUES (7456, 6128, 4192, 4);
  INSERT INTO CONTIENE VALUES (7457, 6160, 4173, 4);
  INSERT INTO CONTIENE VALUES (7458, 6061, 4055, 4);
  INSERT INTO CONTIENE VALUES (7458, 6063, 4055, 1);
  INSERT INTO CONTIENE VALUES (7459, 6055, 4146, 1);
  COMMIT;
END;

--bloque 10
BEGIN
  INSERT INTO CONTIENE VALUES (7459, 6059, 4146, 4);
  INSERT INTO CONTIENE VALUES (7459, 6062, 4146, 3);
  INSERT INTO CONTIENE VALUES (7460, 6086, 4032, 4);
  INSERT INTO CONTIENE VALUES (7460, 6101, 4032, 2);
  INSERT INTO CONTIENE VALUES (7461, 6064, 4122, 1);
  INSERT INTO CONTIENE VALUES (7462, 6120, 4079, 4);
  INSERT INTO CONTIENE VALUES (7463, 6129, 4098, 4);
  INSERT INTO CONTIENE VALUES (7463, 6195, 4098, 3);
  INSERT INTO CONTIENE VALUES (7464, 6046, 4043, 2);
  INSERT INTO CONTIENE VALUES (7464, 6059, 4043, 1);
  INSERT INTO CONTIENE VALUES (7465, 6071, 4016, 2);
  INSERT INTO CONTIENE VALUES (7466, 6063, 4198, 4);
  INSERT INTO CONTIENE VALUES (7467, 6198, 4106, 4);
  INSERT INTO CONTIENE VALUES (7467, 6192, 4106, 3);
  INSERT INTO CONTIENE VALUES (7468, 6058, 4155, 2);
  INSERT INTO CONTIENE VALUES (7469, 6075, 4043, 1);
  INSERT INTO CONTIENE VALUES (7469, 6044, 4043, 2);
  INSERT INTO CONTIENE VALUES (7469, 6048, 4043, 3);
  INSERT INTO CONTIENE VALUES (7470, 6132, 4103, 1);
  INSERT INTO CONTIENE VALUES (7470, 6194, 4103, 2);
  INSERT INTO CONTIENE VALUES (7470, 6180, 4103, 3);
  INSERT INTO CONTIENE VALUES (7471, 6103, 4031, 4);
  INSERT INTO CONTIENE VALUES (7471, 6095, 4031, 3);
  INSERT INTO CONTIENE VALUES (7472, 6069, 4161, 3);
  INSERT INTO CONTIENE VALUES (7472, 6082, 4161, 2);
  INSERT INTO CONTIENE VALUES (7472, 6081, 4161, 4);
  INSERT INTO CONTIENE VALUES (7473, 6062, 4131, 1);
  INSERT INTO CONTIENE VALUES (7474, 6001, 4018, 1);
  INSERT INTO CONTIENE VALUES (7474, 6065, 4018, 4);
  INSERT INTO CONTIENE VALUES (7475, 6065, 4027, 3);
  INSERT INTO CONTIENE VALUES (7475, 6002, 4027, 4);
  INSERT INTO CONTIENE VALUES (7476, 6123, 4078, 3);
  INSERT INTO CONTIENE VALUES (7477, 6053, 4151, 2);
  INSERT INTO CONTIENE VALUES (7477, 6051, 4151, 1);
  INSERT INTO CONTIENE VALUES (7478, 6070, 4057, 1);
  INSERT INTO CONTIENE VALUES (7479, 6189, 4103, 4);
  INSERT INTO CONTIENE VALUES (7479, 6188, 4103, 1);
  INSERT INTO CONTIENE VALUES (7480, 6061, 4114, 1);
  INSERT INTO CONTIENE VALUES (7481, 6076, 4051, 2);
  INSERT INTO CONTIENE VALUES (7481, 6065, 4051, 2);
  INSERT INTO CONTIENE VALUES (7482, 6061, 4156, 4);
  INSERT INTO CONTIENE VALUES (7483, 6068, 4199, 2);
  INSERT INTO CONTIENE VALUES (7484, 6059, 4198, 1);
  INSERT INTO CONTIENE VALUES (7485, 6087, 4033, 2);
  INSERT INTO CONTIENE VALUES (7486, 6113, 4079, 3);
  INSERT INTO CONTIENE VALUES (7487, 6069, 4170, 2);
  INSERT INTO CONTIENE VALUES (7488, 6062, 4143, 3);
  INSERT INTO CONTIENE VALUES (7488, 6058, 4143, 4);
  INSERT INTO CONTIENE VALUES (7488, 6057, 4143, 1);
  INSERT INTO CONTIENE VALUES (7489, 6040, 4138, 1);
  INSERT INTO CONTIENE VALUES (7489, 6068, 4138, 1);
  INSERT INTO CONTIENE VALUES (7490, 6110, 4086, 1);
  INSERT INTO CONTIENE VALUES (7490, 6118, 4086, 1);
  INSERT INTO CONTIENE VALUES (7490, 6167, 4086, 3);
  INSERT INTO CONTIENE VALUES (7491, 6050, 4183, 4);
  INSERT INTO CONTIENE VALUES (7491, 6076, 4183, 2);
  INSERT INTO CONTIENE VALUES (7492, 6061, 4008, 1);
  INSERT INTO CONTIENE VALUES (7492, 6062, 4008, 3);
  INSERT INTO CONTIENE VALUES (7492, 6003, 4008, 3);
  INSERT INTO CONTIENE VALUES (7493, 6021, 4118, 4);
  INSERT INTO CONTIENE VALUES (7494, 6102, 4168, 1);
  INSERT INTO CONTIENE VALUES (7494, 6070, 4168, 4);
  INSERT INTO CONTIENE VALUES (7495, 6050, 4050, 2);
  INSERT INTO CONTIENE VALUES (7495, 6043, 4050, 3);
  INSERT INTO CONTIENE VALUES (7495, 6066, 4050, 3);
  INSERT INTO CONTIENE VALUES (7496, 6069, 4061, 2);
  INSERT INTO CONTIENE VALUES (7496, 6015, 4061, 4);
  INSERT INTO CONTIENE VALUES (7496, 6068, 4061, 3);
  INSERT INTO CONTIENE VALUES (7497, 6063, 4012, 1);
  INSERT INTO CONTIENE VALUES (7498, 6108, 4187, 1);
  INSERT INTO CONTIENE VALUES (7498, 6166, 4187, 4);
  INSERT INTO CONTIENE VALUES (7499, 6185, 4106, 4);
  INSERT INTO CONTIENE VALUES (7500, 6024, 4121, 2);
  COMMIT;
END;


--RECIBE 
--bloque-1
BEGIN
  INSERT INTO RECIBE VALUES (7001, 4069);
  INSERT INTO RECIBE VALUES (7002, 4028);
  INSERT INTO RECIBE VALUES (7003, 4041);
  INSERT INTO RECIBE VALUES (7004, 4086);
  INSERT INTO RECIBE VALUES (7005, 4002);
  INSERT INTO RECIBE VALUES (7006, 4012);
  INSERT INTO RECIBE VALUES (7007, 4006);
  INSERT INTO RECIBE VALUES (7008, 4123);
  INSERT INTO RECIBE VALUES (7009, 4156);
  INSERT INTO RECIBE VALUES (7010, 4102);
  INSERT INTO RECIBE VALUES (7011, 4138);
  INSERT INTO RECIBE VALUES (7012, 4047);
  INSERT INTO RECIBE VALUES (7013, 4101);
  INSERT INTO RECIBE VALUES (7014, 4151);
  INSERT INTO RECIBE VALUES (7015, 4091);
  INSERT INTO RECIBE VALUES (7016, 4129);
  INSERT INTO RECIBE VALUES (7017, 4138);
  INSERT INTO RECIBE VALUES (7018, 4012);
  INSERT INTO RECIBE VALUES (7019, 4066);
  INSERT INTO RECIBE VALUES (7020, 4163);
  INSERT INTO RECIBE VALUES (7021, 4091);
  INSERT INTO RECIBE VALUES (7022, 4178);
  INSERT INTO RECIBE VALUES (7023, 4193);
  INSERT INTO RECIBE VALUES (7024, 4090);
  INSERT INTO RECIBE VALUES (7025, 4184);
  INSERT INTO RECIBE VALUES (7026, 4061);
  INSERT INTO RECIBE VALUES (7027, 4198);
  INSERT INTO RECIBE VALUES (7028, 4043);
  INSERT INTO RECIBE VALUES (7029, 4116);
  INSERT INTO RECIBE VALUES (7030, 4134);
  INSERT INTO RECIBE VALUES (7031, 4129);
  INSERT INTO RECIBE VALUES (7032, 4088);
  INSERT INTO RECIBE VALUES (7033, 4012);
  INSERT INTO RECIBE VALUES (7034, 4050);
  INSERT INTO RECIBE VALUES (7035, 4154);
  INSERT INTO RECIBE VALUES (7036, 4142);
  INSERT INTO RECIBE VALUES (7037, 4188);
  INSERT INTO RECIBE VALUES (7038, 4102);
  INSERT INTO RECIBE VALUES (7039, 4156);
  INSERT INTO RECIBE VALUES (7040, 4172);
  INSERT INTO RECIBE VALUES (7041, 4198);
  INSERT INTO RECIBE VALUES (7042, 4047);
  INSERT INTO RECIBE VALUES (7043, 4097);
  INSERT INTO RECIBE VALUES (7044, 4018);
  INSERT INTO RECIBE VALUES (7045, 4098);
  INSERT INTO RECIBE VALUES (7046, 4028);
  INSERT INTO RECIBE VALUES (7047, 4115);
  INSERT INTO RECIBE VALUES (7048, 4013);
  INSERT INTO RECIBE VALUES (7049, 4128);
  INSERT INTO RECIBE VALUES (7050, 4095);
  INSERT INTO RECIBE VALUES (7051, 4154);
  INSERT INTO RECIBE VALUES (7052, 4017);
  INSERT INTO RECIBE VALUES (7053, 4156);
  INSERT INTO RECIBE VALUES (7054, 4043);
  INSERT INTO RECIBE VALUES (7055, 4120);
  INSERT INTO RECIBE VALUES (7056, 4157);
  INSERT INTO RECIBE VALUES (7057, 4101);
  INSERT INTO RECIBE VALUES (7058, 4111);
  INSERT INTO RECIBE VALUES (7059, 4050);
  INSERT INTO RECIBE VALUES (7060, 4063);
  INSERT INTO RECIBE VALUES (7061, 4007);
  INSERT INTO RECIBE VALUES (7062, 4064);
  INSERT INTO RECIBE VALUES (7063, 4078);
  INSERT INTO RECIBE VALUES (7064, 4165);
  INSERT INTO RECIBE VALUES (7065, 4107);
  INSERT INTO RECIBE VALUES (7066, 4144);
  INSERT INTO RECIBE VALUES (7067, 4074);
  INSERT INTO RECIBE VALUES (7068, 4185);
  INSERT INTO RECIBE VALUES (7069, 4134);
  INSERT INTO RECIBE VALUES (7070, 4013);
  INSERT INTO RECIBE VALUES (7071, 4022);
  INSERT INTO RECIBE VALUES (7072, 4036);
  INSERT INTO RECIBE VALUES (7073, 4026);
  INSERT INTO RECIBE VALUES (7074, 4111);
  INSERT INTO RECIBE VALUES (7075, 4039);
  INSERT INTO RECIBE VALUES (7076, 4024);
  INSERT INTO RECIBE VALUES (7077, 4061);
  INSERT INTO RECIBE VALUES (7078, 4037);
  INSERT INTO RECIBE VALUES (7079, 4016);
  INSERT INTO RECIBE VALUES (7080, 4064);
  INSERT INTO RECIBE VALUES (7081, 4143);
  INSERT INTO RECIBE VALUES (7082, 4143);
  INSERT INTO RECIBE VALUES (7083, 4155);
  INSERT INTO RECIBE VALUES (7084, 4177);
  INSERT INTO RECIBE VALUES (7085, 4076);
  INSERT INTO RECIBE VALUES (7086, 4153);
  INSERT INTO RECIBE VALUES (7087, 4092);
  INSERT INTO RECIBE VALUES (7088, 4067);
  INSERT INTO RECIBE VALUES (7089, 4094);
  INSERT INTO RECIBE VALUES (7090, 4183);
  INSERT INTO RECIBE VALUES (7091, 4019);
  INSERT INTO RECIBE VALUES (7092, 4093);
  INSERT INTO RECIBE VALUES (7093, 4067);
  INSERT INTO RECIBE VALUES (7094, 4196);
  INSERT INTO RECIBE VALUES (7095, 4026);
  INSERT INTO RECIBE VALUES (7096, 4107);
  INSERT INTO RECIBE VALUES (7097, 4107);
  INSERT INTO RECIBE VALUES (7098, 4138);
  INSERT INTO RECIBE VALUES (7099, 4200);
  INSERT INTO RECIBE VALUES (7100, 4007);
  COMMIT;
END;

--bloque-2
BEGIN
  INSERT INTO RECIBE VALUES (7101, 4146);
  INSERT INTO RECIBE VALUES (7102, 4153);
  INSERT INTO RECIBE VALUES (7103, 4073);
  INSERT INTO RECIBE VALUES (7104, 4109);
  INSERT INTO RECIBE VALUES (7105, 4171);
  INSERT INTO RECIBE VALUES (7106, 4115);
  INSERT INTO RECIBE VALUES (7107, 4146);
  INSERT INTO RECIBE VALUES (7108, 4023);
  INSERT INTO RECIBE VALUES (7109, 4080);
  INSERT INTO RECIBE VALUES (7110, 4188);
  INSERT INTO RECIBE VALUES (7111, 4169);
  INSERT INTO RECIBE VALUES (7112, 4039);
  INSERT INTO RECIBE VALUES (7113, 4131);
  INSERT INTO RECIBE VALUES (7114, 4137);
  INSERT INTO RECIBE VALUES (7115, 4149);
  INSERT INTO RECIBE VALUES (7116, 4195);
  INSERT INTO RECIBE VALUES (7117, 4076);
  INSERT INTO RECIBE VALUES (7118, 4044);
  INSERT INTO RECIBE VALUES (7119, 4150);
  INSERT INTO RECIBE VALUES (7120, 4194);
  INSERT INTO RECIBE VALUES (7121, 4147);
  INSERT INTO RECIBE VALUES (7122, 4174);
  INSERT INTO RECIBE VALUES (7123, 4081);
  INSERT INTO RECIBE VALUES (7124, 4061);
  INSERT INTO RECIBE VALUES (7125, 4133);
  INSERT INTO RECIBE VALUES (7126, 4176);
  INSERT INTO RECIBE VALUES (7127, 4129);
  INSERT INTO RECIBE VALUES (7128, 4174);
  INSERT INTO RECIBE VALUES (7129, 4110);
  INSERT INTO RECIBE VALUES (7130, 4082);
  INSERT INTO RECIBE VALUES (7131, 4114);
  INSERT INTO RECIBE VALUES (7132, 4091);
  INSERT INTO RECIBE VALUES (7133, 4060);
  INSERT INTO RECIBE VALUES (7134, 4164);
  INSERT INTO RECIBE VALUES (7135, 4140);
  INSERT INTO RECIBE VALUES (7136, 4031);
  INSERT INTO RECIBE VALUES (7137, 4003);
  INSERT INTO RECIBE VALUES (7138, 4049);
  INSERT INTO RECIBE VALUES (7139, 4085);
  INSERT INTO RECIBE VALUES (7140, 4102);
  INSERT INTO RECIBE VALUES (7141, 4097);
  INSERT INTO RECIBE VALUES (7142, 4049);
  INSERT INTO RECIBE VALUES (7143, 4166);
  INSERT INTO RECIBE VALUES (7144, 4014);
  INSERT INTO RECIBE VALUES (7145, 4086);
  INSERT INTO RECIBE VALUES (7146, 4114);
  INSERT INTO RECIBE VALUES (7147, 4053);
  INSERT INTO RECIBE VALUES (7148, 4074);
  INSERT INTO RECIBE VALUES (7149, 4121);
  INSERT INTO RECIBE VALUES (7150, 4199);
  INSERT INTO RECIBE VALUES (7151, 4122);
  INSERT INTO RECIBE VALUES (7152, 4076);
  INSERT INTO RECIBE VALUES (7153, 4145);
  INSERT INTO RECIBE VALUES (7154, 4107);
  INSERT INTO RECIBE VALUES (7155, 4134);
  INSERT INTO RECIBE VALUES (7156, 4022);
  INSERT INTO RECIBE VALUES (7157, 4162);
  INSERT INTO RECIBE VALUES (7158, 4040);
  INSERT INTO RECIBE VALUES (7159, 4051);
  INSERT INTO RECIBE VALUES (7160, 4047);
  INSERT INTO RECIBE VALUES (7161, 4171);
  INSERT INTO RECIBE VALUES (7162, 4089);
  INSERT INTO RECIBE VALUES (7163, 4119);
  INSERT INTO RECIBE VALUES (7164, 4143);
  INSERT INTO RECIBE VALUES (7165, 4169);
  INSERT INTO RECIBE VALUES (7166, 4079);
  INSERT INTO RECIBE VALUES (7167, 4125);
  INSERT INTO RECIBE VALUES (7168, 4077);
  INSERT INTO RECIBE VALUES (7169, 4151);
  INSERT INTO RECIBE VALUES (7170, 4031);
  INSERT INTO RECIBE VALUES (7171, 4142);
  INSERT INTO RECIBE VALUES (7172, 4020);
  INSERT INTO RECIBE VALUES (7173, 4053);
  INSERT INTO RECIBE VALUES (7174, 4048);
  INSERT INTO RECIBE VALUES (7175, 4019);
  INSERT INTO RECIBE VALUES (7176, 4068);
  INSERT INTO RECIBE VALUES (7177, 4192);
  INSERT INTO RECIBE VALUES (7178, 4127);
  INSERT INTO RECIBE VALUES (7179, 4066);
  INSERT INTO RECIBE VALUES (7180, 4183);
  INSERT INTO RECIBE VALUES (7181, 4062);
  INSERT INTO RECIBE VALUES (7182, 4185);
  INSERT INTO RECIBE VALUES (7183, 4141);
  INSERT INTO RECIBE VALUES (7184, 4094);
  INSERT INTO RECIBE VALUES (7185, 4058);
  INSERT INTO RECIBE VALUES (7186, 4183);
  INSERT INTO RECIBE VALUES (7187, 4172);
  INSERT INTO RECIBE VALUES (7188, 4070);
  INSERT INTO RECIBE VALUES (7189, 4172);
  INSERT INTO RECIBE VALUES (7190, 4136);
  INSERT INTO RECIBE VALUES (7191, 4071);
  INSERT INTO RECIBE VALUES (7192, 4170);
  INSERT INTO RECIBE VALUES (7193, 4078);
  INSERT INTO RECIBE VALUES (7194, 4191);
  INSERT INTO RECIBE VALUES (7195, 4197);
  INSERT INTO RECIBE VALUES (7196, 4160);
  INSERT INTO RECIBE VALUES (7197, 4057);
  INSERT INTO RECIBE VALUES (7198, 4131);
  INSERT INTO RECIBE VALUES (7199, 4161);
  INSERT INTO RECIBE VALUES (7200, 4160);
  COMMIT;
END;

--bloque-3
BEGIN
  INSERT INTO RECIBE VALUES (7201, 4074);
  INSERT INTO RECIBE VALUES (7202, 4040);
  INSERT INTO RECIBE VALUES (7203, 4060);
  INSERT INTO RECIBE VALUES (7204, 4195);
  INSERT INTO RECIBE VALUES (7205, 4051);
  INSERT INTO RECIBE VALUES (7206, 4085);
  INSERT INTO RECIBE VALUES (7207, 4118);
  INSERT INTO RECIBE VALUES (7208, 4035);
  INSERT INTO RECIBE VALUES (7209, 4055);
  INSERT INTO RECIBE VALUES (7210, 4033);
  INSERT INTO RECIBE VALUES (7211, 4049);
  INSERT INTO RECIBE VALUES (7212, 4088);
  INSERT INTO RECIBE VALUES (7213, 4017);
  INSERT INTO RECIBE VALUES (7214, 4084);
  INSERT INTO RECIBE VALUES (7215, 4186);
  INSERT INTO RECIBE VALUES (7216, 4128);
  INSERT INTO RECIBE VALUES (7217, 4017);
  INSERT INTO RECIBE VALUES (7218, 4166);
  INSERT INTO RECIBE VALUES (7219, 4114);
  INSERT INTO RECIBE VALUES (7220, 4130);
  INSERT INTO RECIBE VALUES (7221, 4142);
  INSERT INTO RECIBE VALUES (7222, 4172);
  INSERT INTO RECIBE VALUES (7223, 4169);
  INSERT INTO RECIBE VALUES (7224, 4019);
  INSERT INTO RECIBE VALUES (7225, 4063);
  INSERT INTO RECIBE VALUES (7226, 4197);
  INSERT INTO RECIBE VALUES (7227, 4002);
  INSERT INTO RECIBE VALUES (7228, 4093);
  INSERT INTO RECIBE VALUES (7229, 4180);
  INSERT INTO RECIBE VALUES (7230, 4198);
  INSERT INTO RECIBE VALUES (7231, 4095);
  INSERT INTO RECIBE VALUES (7232, 4054);
  INSERT INTO RECIBE VALUES (7233, 4026);
  INSERT INTO RECIBE VALUES (7234, 4134);
  INSERT INTO RECIBE VALUES (7235, 4186);
  INSERT INTO RECIBE VALUES (7236, 4017);
  INSERT INTO RECIBE VALUES (7237, 4020);
  INSERT INTO RECIBE VALUES (7238, 4119);
  INSERT INTO RECIBE VALUES (7239, 4190);
  INSERT INTO RECIBE VALUES (7240, 4166);
  INSERT INTO RECIBE VALUES (7241, 4024);
  INSERT INTO RECIBE VALUES (7242, 4102);
  INSERT INTO RECIBE VALUES (7243, 4138);
  INSERT INTO RECIBE VALUES (7244, 4175);
  INSERT INTO RECIBE VALUES (7245, 4119);
  INSERT INTO RECIBE VALUES (7246, 4150);
  INSERT INTO RECIBE VALUES (7247, 4064);
  INSERT INTO RECIBE VALUES (7248, 4101);
  INSERT INTO RECIBE VALUES (7249, 4119);
  INSERT INTO RECIBE VALUES (7250, 4056);
  INSERT INTO RECIBE VALUES (7251, 4081);
  INSERT INTO RECIBE VALUES (7252, 4104);
  INSERT INTO RECIBE VALUES (7253, 4187);
  INSERT INTO RECIBE VALUES (7254, 4159);
  INSERT INTO RECIBE VALUES (7255, 4077);
  INSERT INTO RECIBE VALUES (7256, 4011);
  INSERT INTO RECIBE VALUES (7257, 4109);
  INSERT INTO RECIBE VALUES (7258, 4196);
  INSERT INTO RECIBE VALUES (7259, 4142);
  INSERT INTO RECIBE VALUES (7260, 4046);
  INSERT INTO RECIBE VALUES (7261, 4024);
  INSERT INTO RECIBE VALUES (7262, 4172);
  INSERT INTO RECIBE VALUES (7263, 4108);
  INSERT INTO RECIBE VALUES (7264, 4162);
  INSERT INTO RECIBE VALUES (7265, 4046);
  INSERT INTO RECIBE VALUES (7266, 4157);
  INSERT INTO RECIBE VALUES (7267, 4197);
  INSERT INTO RECIBE VALUES (7268, 4084);
  INSERT INTO RECIBE VALUES (7269, 4170);
  INSERT INTO RECIBE VALUES (7270, 4053);
  INSERT INTO RECIBE VALUES (7271, 4142);
  INSERT INTO RECIBE VALUES (7272, 4057);
  INSERT INTO RECIBE VALUES (7273, 4067);
  INSERT INTO RECIBE VALUES (7274, 4192);
  INSERT INTO RECIBE VALUES (7275, 4067);
  INSERT INTO RECIBE VALUES (7276, 4148);
  INSERT INTO RECIBE VALUES (7277, 4190);
  INSERT INTO RECIBE VALUES (7278, 4111);
  INSERT INTO RECIBE VALUES (7279, 4053);
  INSERT INTO RECIBE VALUES (7280, 4167);
  INSERT INTO RECIBE VALUES (7281, 4138);
  INSERT INTO RECIBE VALUES (7282, 4074);
  INSERT INTO RECIBE VALUES (7283, 4016);
  INSERT INTO RECIBE VALUES (7284, 4131);
  INSERT INTO RECIBE VALUES (7285, 4086);
  INSERT INTO RECIBE VALUES (7286, 4148);
  INSERT INTO RECIBE VALUES (7287, 4005);
  INSERT INTO RECIBE VALUES (7288, 4159);
  INSERT INTO RECIBE VALUES (7289, 4184);
  INSERT INTO RECIBE VALUES (7290, 4083);
  INSERT INTO RECIBE VALUES (7291, 4066);
  INSERT INTO RECIBE VALUES (7292, 4074);
  INSERT INTO RECIBE VALUES (7293, 4109);
  INSERT INTO RECIBE VALUES (7294, 4158);
  INSERT INTO RECIBE VALUES (7295, 4074);
  INSERT INTO RECIBE VALUES (7296, 4173);
  INSERT INTO RECIBE VALUES (7297, 4018);
  INSERT INTO RECIBE VALUES (7298, 4171);
  INSERT INTO RECIBE VALUES (7299, 4181);
  INSERT INTO RECIBE VALUES (7300, 4062);
  COMMIT;
END;

--bloque-4
BEGIN
  INSERT INTO RECIBE VALUES (7301, 4177);
  INSERT INTO RECIBE VALUES (7302, 4138);
  INSERT INTO RECIBE VALUES (7303, 4089);
  INSERT INTO RECIBE VALUES (7304, 4061);
  INSERT INTO RECIBE VALUES (7305, 4138);
  INSERT INTO RECIBE VALUES (7306, 4194);
  INSERT INTO RECIBE VALUES (7307, 4017);
  INSERT INTO RECIBE VALUES (7308, 4100);
  INSERT INTO RECIBE VALUES (7309, 4133);
  INSERT INTO RECIBE VALUES (7310, 4014);
  INSERT INTO RECIBE VALUES (7311, 4034);
  INSERT INTO RECIBE VALUES (7312, 4061);
  INSERT INTO RECIBE VALUES (7313, 4035);
  INSERT INTO RECIBE VALUES (7314, 4022);
  INSERT INTO RECIBE VALUES (7315, 4020);
  INSERT INTO RECIBE VALUES (7316, 4185);
  INSERT INTO RECIBE VALUES (7317, 4124);
  INSERT INTO RECIBE VALUES (7318, 4081);
  INSERT INTO RECIBE VALUES (7319, 4142);
  INSERT INTO RECIBE VALUES (7320, 4086);
  INSERT INTO RECIBE VALUES (7321, 4024);
  INSERT INTO RECIBE VALUES (7322, 4072);
  INSERT INTO RECIBE VALUES (7323, 4039);
  INSERT INTO RECIBE VALUES (7324, 4055);
  INSERT INTO RECIBE VALUES (7325, 4195);
  INSERT INTO RECIBE VALUES (7326, 4173);
  INSERT INTO RECIBE VALUES (7327, 4098);
  INSERT INTO RECIBE VALUES (7328, 4110);
  INSERT INTO RECIBE VALUES (7329, 4141);
  INSERT INTO RECIBE VALUES (7330, 4087);
  INSERT INTO RECIBE VALUES (7331, 4013);
  INSERT INTO RECIBE VALUES (7332, 4087);
  INSERT INTO RECIBE VALUES (7333, 4199);
  INSERT INTO RECIBE VALUES (7334, 4088);
  INSERT INTO RECIBE VALUES (7335, 4094);
  INSERT INTO RECIBE VALUES (7336, 4200);
  INSERT INTO RECIBE VALUES (7337, 4008);
  INSERT INTO RECIBE VALUES (7338, 4192);
  INSERT INTO RECIBE VALUES (7339, 4155);
  INSERT INTO RECIBE VALUES (7340, 4172);
  INSERT INTO RECIBE VALUES (7341, 4152);
  INSERT INTO RECIBE VALUES (7342, 4164);
  INSERT INTO RECIBE VALUES (7343, 4094);
  INSERT INTO RECIBE VALUES (7344, 4005);
  INSERT INTO RECIBE VALUES (7345, 4177);
  INSERT INTO RECIBE VALUES (7346, 4005);
  INSERT INTO RECIBE VALUES (7347, 4008);
  INSERT INTO RECIBE VALUES (7348, 4114);
  INSERT INTO RECIBE VALUES (7349, 4167);
  INSERT INTO RECIBE VALUES (7350, 4158);
  INSERT INTO RECIBE VALUES (7351, 4082);
  INSERT INTO RECIBE VALUES (7352, 4082);
  INSERT INTO RECIBE VALUES (7353, 4027);
  INSERT INTO RECIBE VALUES (7354, 4067);
  INSERT INTO RECIBE VALUES (7355, 4189);
  INSERT INTO RECIBE VALUES (7356, 4160);
  INSERT INTO RECIBE VALUES (7357, 4178);
  INSERT INTO RECIBE VALUES (7358, 4122);
  INSERT INTO RECIBE VALUES (7359, 4161);
  INSERT INTO RECIBE VALUES (7360, 4085);
  INSERT INTO RECIBE VALUES (7361, 4190);
  INSERT INTO RECIBE VALUES (7362, 4096);
  INSERT INTO RECIBE VALUES (7363, 4154);
  INSERT INTO RECIBE VALUES (7364, 4124);
  INSERT INTO RECIBE VALUES (7365, 4015);
  INSERT INTO RECIBE VALUES (7366, 4126);
  INSERT INTO RECIBE VALUES (7367, 4097);
  INSERT INTO RECIBE VALUES (7368, 4019);
  INSERT INTO RECIBE VALUES (7369, 4149);
  INSERT INTO RECIBE VALUES (7370, 4123);
  INSERT INTO RECIBE VALUES (7371, 4033);
  INSERT INTO RECIBE VALUES (7372, 4127);
  INSERT INTO RECIBE VALUES (7373, 4097);
  INSERT INTO RECIBE VALUES (7374, 4007);
  INSERT INTO RECIBE VALUES (7375, 4063);
  INSERT INTO RECIBE VALUES (7376, 4130);
  INSERT INTO RECIBE VALUES (7377, 4031);
  INSERT INTO RECIBE VALUES (7378, 4020);
  INSERT INTO RECIBE VALUES (7379, 4009);
  INSERT INTO RECIBE VALUES (7380, 4019);
  INSERT INTO RECIBE VALUES (7381, 4172);
  INSERT INTO RECIBE VALUES (7382, 4102);
  INSERT INTO RECIBE VALUES (7383, 4061);
  INSERT INTO RECIBE VALUES (7384, 4020);
  INSERT INTO RECIBE VALUES (7385, 4178);
  INSERT INTO RECIBE VALUES (7386, 4096);
  INSERT INTO RECIBE VALUES (7387, 4048);
  INSERT INTO RECIBE VALUES (7388, 4015);
  INSERT INTO RECIBE VALUES (7389, 4131);
  INSERT INTO RECIBE VALUES (7390, 4036);
  INSERT INTO RECIBE VALUES (7391, 4123);
  INSERT INTO RECIBE VALUES (7392, 4088);
  INSERT INTO RECIBE VALUES (7393, 4087);
  INSERT INTO RECIBE VALUES (7394, 4147);
  INSERT INTO RECIBE VALUES (7395, 4185);
  INSERT INTO RECIBE VALUES (7396, 4179);
  INSERT INTO RECIBE VALUES (7397, 4186);
  INSERT INTO RECIBE VALUES (7398, 4001);
  INSERT INTO RECIBE VALUES (7399, 4012);
  INSERT INTO RECIBE VALUES (7400, 4031);
  COMMIT;
END;

--bloque-5
BEGIN
  INSERT INTO RECIBE VALUES (7401, 4166);
  INSERT INTO RECIBE VALUES (7402, 4184);
  INSERT INTO RECIBE VALUES (7403, 4008);
  INSERT INTO RECIBE VALUES (7404, 4144);
  INSERT INTO RECIBE VALUES (7405, 4183);
  INSERT INTO RECIBE VALUES (7406, 4163);
  INSERT INTO RECIBE VALUES (7407, 4199);
  INSERT INTO RECIBE VALUES (7408, 4004);
  INSERT INTO RECIBE VALUES (7409, 4069);
  INSERT INTO RECIBE VALUES (7410, 4184);
  INSERT INTO RECIBE VALUES (7411, 4004);
  INSERT INTO RECIBE VALUES (7412, 4099);
  INSERT INTO RECIBE VALUES (7413, 4036);
  INSERT INTO RECIBE VALUES (7414, 4031);
  INSERT INTO RECIBE VALUES (7415, 4166);
  INSERT INTO RECIBE VALUES (7416, 4152);
  INSERT INTO RECIBE VALUES (7417, 4071);
  INSERT INTO RECIBE VALUES (7418, 4053);
  INSERT INTO RECIBE VALUES (7419, 4048);
  INSERT INTO RECIBE VALUES (7420, 4035);
  INSERT INTO RECIBE VALUES (7421, 4034);
  INSERT INTO RECIBE VALUES (7422, 4159);
  INSERT INTO RECIBE VALUES (7423, 4009);
  INSERT INTO RECIBE VALUES (7424, 4186);
  INSERT INTO RECIBE VALUES (7425, 4115);
  INSERT INTO RECIBE VALUES (7426, 4140);
  INSERT INTO RECIBE VALUES (7427, 4179);
  INSERT INTO RECIBE VALUES (7428, 4065);
  INSERT INTO RECIBE VALUES (7429, 4193);
  INSERT INTO RECIBE VALUES (7430, 4129);
  INSERT INTO RECIBE VALUES (7431, 4182);
  INSERT INTO RECIBE VALUES (7432, 4055);
  INSERT INTO RECIBE VALUES (7433, 4034);
  INSERT INTO RECIBE VALUES (7434, 4190);
  INSERT INTO RECIBE VALUES (7435, 4034);
  INSERT INTO RECIBE VALUES (7436, 4119);
  INSERT INTO RECIBE VALUES (7437, 4057);
  INSERT INTO RECIBE VALUES (7438, 4144);
  INSERT INTO RECIBE VALUES (7439, 4130);
  INSERT INTO RECIBE VALUES (7440, 4152);
  INSERT INTO RECIBE VALUES (7441, 4083);
  INSERT INTO RECIBE VALUES (7442, 4200);
  INSERT INTO RECIBE VALUES (7443, 4039);
  INSERT INTO RECIBE VALUES (7444, 4115);
  INSERT INTO RECIBE VALUES (7445, 4056);
  INSERT INTO RECIBE VALUES (7446, 4182);
  INSERT INTO RECIBE VALUES (7447, 4041);
  INSERT INTO RECIBE VALUES (7448, 4140);
  INSERT INTO RECIBE VALUES (7449, 4040);
  INSERT INTO RECIBE VALUES (7450, 4129);
  INSERT INTO RECIBE VALUES (7451, 4038);
  INSERT INTO RECIBE VALUES (7452, 4164);
  INSERT INTO RECIBE VALUES (7453, 4176);
  INSERT INTO RECIBE VALUES (7454, 4198);
  INSERT INTO RECIBE VALUES (7455, 4020);
  INSERT INTO RECIBE VALUES (7456, 4192);
  INSERT INTO RECIBE VALUES (7457, 4173);
  INSERT INTO RECIBE VALUES (7458, 4055);
  INSERT INTO RECIBE VALUES (7459, 4146);
  INSERT INTO RECIBE VALUES (7460, 4032);
  INSERT INTO RECIBE VALUES (7461, 4122);
  INSERT INTO RECIBE VALUES (7462, 4079);
  INSERT INTO RECIBE VALUES (7463, 4098);
  INSERT INTO RECIBE VALUES (7464, 4043);
  INSERT INTO RECIBE VALUES (7465, 4016);
  INSERT INTO RECIBE VALUES (7466, 4198);
  INSERT INTO RECIBE VALUES (7467, 4106);
  INSERT INTO RECIBE VALUES (7468, 4155);
  INSERT INTO RECIBE VALUES (7469, 4043);
  INSERT INTO RECIBE VALUES (7470, 4103);
  INSERT INTO RECIBE VALUES (7471, 4031);
  INSERT INTO RECIBE VALUES (7472, 4161);
  INSERT INTO RECIBE VALUES (7473, 4131);
  INSERT INTO RECIBE VALUES (7474, 4018);
  INSERT INTO RECIBE VALUES (7475, 4027);
  INSERT INTO RECIBE VALUES (7476, 4078);
  INSERT INTO RECIBE VALUES (7477, 4151);
  INSERT INTO RECIBE VALUES (7478, 4057);
  INSERT INTO RECIBE VALUES (7479, 4103);
  INSERT INTO RECIBE VALUES (7480, 4114);
  INSERT INTO RECIBE VALUES (7481, 4051);
  INSERT INTO RECIBE VALUES (7482, 4156);
  INSERT INTO RECIBE VALUES (7483, 4199);
  INSERT INTO RECIBE VALUES (7484, 4198);
  INSERT INTO RECIBE VALUES (7485, 4033);
  INSERT INTO RECIBE VALUES (7486, 4079);
  INSERT INTO RECIBE VALUES (7487, 4170);
  INSERT INTO RECIBE VALUES (7488, 4143);
  INSERT INTO RECIBE VALUES (7489, 4138);
  INSERT INTO RECIBE VALUES (7490, 4086);
  INSERT INTO RECIBE VALUES (7491, 4183);
  INSERT INTO RECIBE VALUES (7492, 4008);
  INSERT INTO RECIBE VALUES (7493, 4118);
  INSERT INTO RECIBE VALUES (7494, 4168);
  INSERT INTO RECIBE VALUES (7495, 4050);
  INSERT INTO RECIBE VALUES (7496, 4061);
  INSERT INTO RECIBE VALUES (7497, 4012);
  INSERT INTO RECIBE VALUES (7498, 4187);
  INSERT INTO RECIBE VALUES (7499, 4106);
  INSERT INTO RECIBE VALUES (7500, 4121);
  COMMIT;
END;


--PAGO 
--bloque 1
BEGIN
  INSERT INTO PAGO VALUES (8001, 'Tarjeta', 214.28, 'Pagado', TO_DATE('2026-03-08', 'YYYY-MM-DD'), 7001);
  INSERT INTO PAGO VALUES (8002, 'Efectivo', 151.78, 'Pagado', TO_DATE('2026-04-12', 'YYYY-MM-DD'), 7002);
  INSERT INTO PAGO VALUES (8003, 'Transferencia', 222.84, 'Reembolsado', TO_DATE('2026-03-17', 'YYYY-MM-DD'), 7003);
  INSERT INTO PAGO VALUES (8004, 'Transferencia', 123.70, 'Pagado', TO_DATE('2026-01-13', 'YYYY-MM-DD'), 7004);
  INSERT INTO PAGO VALUES (8005, 'Tarjeta', 130.63, 'Rechazado', TO_DATE('2026-02-13', 'YYYY-MM-DD'), 7005);
  INSERT INTO PAGO VALUES (8006, 'App', 101.99, 'Rechazado', TO_DATE('2026-01-30', 'YYYY-MM-DD'), 7006);
  INSERT INTO PAGO VALUES (8007, 'Tarjeta', 201.25, 'Pagado', TO_DATE('2026-01-20', 'YYYY-MM-DD'), 7007);
  INSERT INTO PAGO VALUES (8008, 'Efectivo', 160.84, 'Pendiente', TO_DATE('2026-04-10', 'YYYY-MM-DD'), 7008);
  INSERT INTO PAGO VALUES (8009, 'QR', 95.83, 'Pagado', TO_DATE('2026-04-05', 'YYYY-MM-DD'), 7009);
  INSERT INTO PAGO VALUES (8010, 'App', 127.35, 'Rechazado', TO_DATE('2026-03-11', 'YYYY-MM-DD'), 7010);
  INSERT INTO PAGO VALUES (8011, 'Efectivo', 188.17, 'Reembolsado', TO_DATE('2026-02-22', 'YYYY-MM-DD'), 7011);
  INSERT INTO PAGO VALUES (8012, 'Transferencia', 125.86, 'Pagado', TO_DATE('2026-03-29', 'YYYY-MM-DD'), 7012);
  INSERT INTO PAGO VALUES (8013, 'App', 159.04, 'Pagado', TO_DATE('2026-03-22', 'YYYY-MM-DD'), 7013);
  INSERT INTO PAGO VALUES (8014, 'Transferencia', 221.72, 'Pagado', TO_DATE('2026-01-28', 'YYYY-MM-DD'), 7014);
  INSERT INTO PAGO VALUES (8015, 'QR', 56.63, 'Pagado', TO_DATE('2026-02-17', 'YYYY-MM-DD'), 7015);
  INSERT INTO PAGO VALUES (8016, 'Tarjeta', 164.73, 'Pagado', TO_DATE('2026-03-12', 'YYYY-MM-DD'), 7016);
  INSERT INTO PAGO VALUES (8017, 'Efectivo', 44.40, 'Rechazado', TO_DATE('2026-02-05', 'YYYY-MM-DD'), 7017);
  INSERT INTO PAGO VALUES (8018, 'Transferencia', 48.06, 'Pagado', TO_DATE('2026-03-18', 'YYYY-MM-DD'), 7018);
  INSERT INTO PAGO VALUES (8019, 'Tarjeta', 51.52, 'Rechazado', TO_DATE('2026-02-14', 'YYYY-MM-DD'), 7019);
  INSERT INTO PAGO VALUES (8020, 'Transferencia', 42.48, 'Rechazado', TO_DATE('2026-03-02', 'YYYY-MM-DD'), 7020);
  INSERT INTO PAGO VALUES (8021, 'Transferencia', 133.00, 'Pendiente', TO_DATE('2026-01-17', 'YYYY-MM-DD'), 7021);
  INSERT INTO PAGO VALUES (8022, 'Transferencia', 147.92, 'Reembolsado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7022);
  INSERT INTO PAGO VALUES (8023, 'QR', 124.64, 'Pagado', TO_DATE('2026-02-16', 'YYYY-MM-DD'), 7023);
  INSERT INTO PAGO VALUES (8024, 'Tarjeta', 68.32, 'Pagado', TO_DATE('2026-01-31', 'YYYY-MM-DD'), 7024);
  INSERT INTO PAGO VALUES (8025, 'Efectivo', 196.44, 'Rechazado', TO_DATE('2026-02-19', 'YYYY-MM-DD'), 7025);
  INSERT INTO PAGO VALUES (8026, 'Efectivo', 94.75, 'Pagado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7026);
  INSERT INTO PAGO VALUES (8027, 'Transferencia', 133.51, 'Pagado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7027);
  INSERT INTO PAGO VALUES (8028, 'Tarjeta', 96.06, 'Pagado', TO_DATE('2026-03-13', 'YYYY-MM-DD'), 7028);
  INSERT INTO PAGO VALUES (8029, 'QR', 135.19, 'Pagado', TO_DATE('2026-03-13', 'YYYY-MM-DD'), 7028);
  INSERT INTO PAGO VALUES (8030, 'App', 97.46, 'Pagado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7029);
  INSERT INTO PAGO VALUES (8031, 'Efectivo', 148.46, 'Pagado', TO_DATE('2026-02-12', 'YYYY-MM-DD'), 7030);
  INSERT INTO PAGO VALUES (8032, 'QR', 119.82, 'Pagado', TO_DATE('2026-04-09', 'YYYY-MM-DD'), 7031);
  INSERT INTO PAGO VALUES (8033, 'App', 101.27, 'Rechazado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7032);
  INSERT INTO PAGO VALUES (8034, 'App', 235.15, 'Rechazado', TO_DATE('2026-01-30', 'YYYY-MM-DD'), 7033);
  INSERT INTO PAGO VALUES (8035, 'App', 194.27, 'Pendiente', TO_DATE('2026-03-25', 'YYYY-MM-DD'), 7034);
  INSERT INTO PAGO VALUES (8036, 'Efectivo', 171.69, 'Rechazado', TO_DATE('2026-01-10', 'YYYY-MM-DD'), 7035);
  INSERT INTO PAGO VALUES (8037, 'QR', 203.20, 'Pendiente', TO_DATE('2026-03-21', 'YYYY-MM-DD'), 7036);
  INSERT INTO PAGO VALUES (8038, 'App', 165.73, 'Pagado', TO_DATE('2026-02-07', 'YYYY-MM-DD'), 7037);
  INSERT INTO PAGO VALUES (8039, 'Efectivo', 102.26, 'Pagado', TO_DATE('2026-02-22', 'YYYY-MM-DD'), 7038);
  INSERT INTO PAGO VALUES (8040, 'QR', 198.86, 'Pagado', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7039);
  INSERT INTO PAGO VALUES (8041, 'App', 121.28, 'Pagado', TO_DATE('2026-03-01', 'YYYY-MM-DD'), 7040);
  INSERT INTO PAGO VALUES (8042, 'QR', 43.14, 'Pagado', TO_DATE('2026-04-05', 'YYYY-MM-DD'), 7041);
  INSERT INTO PAGO VALUES (8043, 'QR', 76.54, 'Pagado', TO_DATE('2026-03-11', 'YYYY-MM-DD'), 7042);
  INSERT INTO PAGO VALUES (8044, 'Transferencia', 56.97, 'Pagado', TO_DATE('2026-03-11', 'YYYY-MM-DD'), 7042);
  INSERT INTO PAGO VALUES (8045, 'Tarjeta', 148.46, 'Pagado', TO_DATE('2026-02-22', 'YYYY-MM-DD'), 7043);
  INSERT INTO PAGO VALUES (8046, 'Tarjeta', 211.58, 'Pagado', TO_DATE('2026-01-26', 'YYYY-MM-DD'), 7044);
  INSERT INTO PAGO VALUES (8047, 'QR', 160.84, 'Pagado', TO_DATE('2026-02-18', 'YYYY-MM-DD'), 7045);
  INSERT INTO PAGO VALUES (8048, 'Tarjeta', 115.54, 'Pagado', TO_DATE('2026-01-31', 'YYYY-MM-DD'), 7046);
  INSERT INTO PAGO VALUES (8049, 'Tarjeta', 95.83, 'Pendiente', TO_DATE('2026-01-28', 'YYYY-MM-DD'), 7047);
  INSERT INTO PAGO VALUES (8050, 'Tarjeta', 174.52, 'Reembolsado', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7048);
  INSERT INTO PAGO VALUES (8051, 'Efectivo', 188.17, 'Pagado', TO_DATE('2026-01-13', 'YYYY-MM-DD'), 7049);
  INSERT INTO PAGO VALUES (8052, 'QR', 127.35, 'Rechazado', TO_DATE('2026-03-09', 'YYYY-MM-DD'), 7050);
  INSERT INTO PAGO VALUES (8053, 'QR', 36.43, 'Rechazado', TO_DATE('2026-03-02', 'YYYY-MM-DD'), 7051);
  INSERT INTO PAGO VALUES (8054, 'Efectivo', 81.33, 'Pendiente', TO_DATE('2026-02-14', 'YYYY-MM-DD'), 7052);
  INSERT INTO PAGO VALUES (8055, 'Tarjeta', 72.93, 'Pagado', TO_DATE('2026-01-17', 'YYYY-MM-DD'), 7053);
  INSERT INTO PAGO VALUES (8056, 'App', 58.74, 'Pagado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7054);
  INSERT INTO PAGO VALUES (8057, 'Efectivo', 131.54, 'Pagado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7054);
  INSERT INTO PAGO VALUES (8058, 'Transferencia', 48.06, 'Pagado', TO_DATE('2026-03-10', 'YYYY-MM-DD'), 7055);
  INSERT INTO PAGO VALUES (8059, 'Tarjeta', 133.00, 'Reembolsado', TO_DATE('2026-04-18', 'YYYY-MM-DD'), 7056);
  INSERT INTO PAGO VALUES (8060, 'App', 170.83, 'Rechazado', TO_DATE('2026-03-18', 'YYYY-MM-DD'), 7057);
  INSERT INTO PAGO VALUES (8061, 'Tarjeta', 165.71, 'Pagado', TO_DATE('2026-01-09', 'YYYY-MM-DD'), 7058);
  INSERT INTO PAGO VALUES (8062, 'Efectivo', 64.91, 'Pendiente', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7059);
  INSERT INTO PAGO VALUES (8063, 'QR', 44.82, 'Pagado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7060);
  INSERT INTO PAGO VALUES (8064, 'App', 119.26, 'Rechazado', TO_DATE('2026-03-08', 'YYYY-MM-DD'), 7061);
  INSERT INTO PAGO VALUES (8065, 'Efectivo', 231.25, 'Reembolsado', TO_DATE('2026-04-27', 'YYYY-MM-DD'), 7062);
  INSERT INTO PAGO VALUES (8066, 'Transferencia', 97.46, 'Pagado', TO_DATE('2026-03-16', 'YYYY-MM-DD'), 7063);
  INSERT INTO PAGO VALUES (8067, 'App', 119.82, 'Pagado', TO_DATE('2026-02-04', 'YYYY-MM-DD'), 7064);
  INSERT INTO PAGO VALUES (8068, 'Transferencia', 227.09, 'Pagado', TO_DATE('2026-03-11', 'YYYY-MM-DD'), 7065);
  INSERT INTO PAGO VALUES (8069, 'QR', 103.56, 'Pagado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7066);
  INSERT INTO PAGO VALUES (8070, 'Tarjeta', 171.69, 'Pagado', TO_DATE('2026-03-05', 'YYYY-MM-DD'), 7067);
  INSERT INTO PAGO VALUES (8071, 'Efectivo', 203.20, 'Rechazado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7068);
  INSERT INTO PAGO VALUES (8072, 'Transferencia', 165.73, 'Pagado', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7069);
  INSERT INTO PAGO VALUES (8073, 'Tarjeta', 198.86, 'Rechazado', TO_DATE('2026-03-05', 'YYYY-MM-DD'), 7070);
  INSERT INTO PAGO VALUES (8074, 'Transferencia', 205.86, 'Rechazado', TO_DATE('2026-04-12', 'YYYY-MM-DD'), 7071);
  INSERT INTO PAGO VALUES (8075, 'Transferencia', 216.71, 'Pendiente', TO_DATE('2026-03-12', 'YYYY-MM-DD'), 7072);
  INSERT INTO PAGO VALUES (8076, 'Transferencia', 133.39, 'Reembolsado', TO_DATE('2026-04-03', 'YYYY-MM-DD'), 7077);
  INSERT INTO PAGO VALUES (8077, 'QR', 121.28, 'Pagado', TO_DATE('2026-03-11', 'YYYY-MM-DD'), 7078);
  INSERT INTO PAGO VALUES (8078, 'Tarjeta', 40.85, 'Pagado', TO_DATE('2026-02-22', 'YYYY-MM-DD'), 7079);
  INSERT INTO PAGO VALUES (8079, 'Efectivo', 217.38, 'Rechazado', TO_DATE('2026-01-26', 'YYYY-MM-DD'), 7080);
  INSERT INTO PAGO VALUES (8080, 'Efectivo', 77.29, 'Pagado', TO_DATE('2026-02-18', 'YYYY-MM-DD'), 7081);
  INSERT INTO PAGO VALUES (8081, 'Transferencia', 133.40, 'Pagado', TO_DATE('2026-01-31', 'YYYY-MM-DD'), 7082);
  INSERT INTO PAGO VALUES (8082, 'Efectivo', 231.28, 'Pagado', TO_DATE('2026-01-28', 'YYYY-MM-DD'), 7083);
  INSERT INTO PAGO VALUES (8083, 'App', 115.54, 'Pagado', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7084);
  INSERT INTO PAGO VALUES (8084, 'Efectivo', 133.15, 'Pagado', TO_DATE('2026-01-13', 'YYYY-MM-DD'), 7085);
  INSERT INTO PAGO VALUES (8085, 'QR', 174.52, 'Pagado', TO_DATE('2026-03-09', 'YYYY-MM-DD'), 7086);
  INSERT INTO PAGO VALUES (8086, 'App', 165.75, 'Rechazado', TO_DATE('2026-03-02', 'YYYY-MM-DD'), 7087);
  INSERT INTO PAGO VALUES (8087, 'App', 36.43, 'Rechazado', TO_DATE('2026-02-14', 'YYYY-MM-DD'), 7088);
  INSERT INTO PAGO VALUES (8088, 'App', 81.33, 'Pendiente', TO_DATE('2026-01-17', 'YYYY-MM-DD'), 7089);
  INSERT INTO PAGO VALUES (8089, 'Efectivo', 72.93, 'Rechazado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7090);
  INSERT INTO PAGO VALUES (8090, 'QR', 190.28, 'Pendiente', TO_DATE('2026-02-16', 'YYYY-MM-DD'), 7091);
  INSERT INTO PAGO VALUES (8091, 'App', 151.78, 'Pagado', TO_DATE('2026-01-31', 'YYYY-MM-DD'), 7092);
  INSERT INTO PAGO VALUES (8092, 'Efectivo', 101.44, 'Pagado', TO_DATE('2026-02-19', 'YYYY-MM-DD'), 7093);
  INSERT INTO PAGO VALUES (8093, 'QR', 123.63, 'Pagado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7094);
  INSERT INTO PAGO VALUES (8094, 'App', 170.83, 'Pagado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7095);
  INSERT INTO PAGO VALUES (8095, 'QR', 165.71, 'Pagado', TO_DATE('2026-03-13', 'YYYY-MM-DD'), 7096);
  INSERT INTO PAGO VALUES (8096, 'Tarjeta', 178.61, 'Rechazado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7097);
  INSERT INTO PAGO VALUES (8097, 'Transferencia', 64.91, 'Rechazado', TO_DATE('2026-02-12', 'YYYY-MM-DD'), 7098);
  INSERT INTO PAGO VALUES (8098, 'App', 44.82, 'Pagado', TO_DATE('2026-04-09', 'YYYY-MM-DD'), 7099);
  INSERT INTO PAGO VALUES (8099, 'Transferencia', 119.26, 'Rechazado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7100);
  INSERT INTO PAGO VALUES (8100, 'App', 213.16, 'Pagado', TO_DATE('2026-01-30', 'YYYY-MM-DD'), 7101);
  COMMIT;
END;

--bloque 2
BEGIN
  INSERT INTO PAGO VALUES (8101, 'App', 51.72, 'Rechazado', TO_DATE('2026-03-25', 'YYYY-MM-DD'), 7102);
  INSERT INTO PAGO VALUES (8102, 'Efectivo', 58.74, 'Pagado', TO_DATE('2026-01-10', 'YYYY-MM-DD'), 7103);
  INSERT INTO PAGO VALUES (8103, 'Efectivo', 232.06, 'Reembolsado', TO_DATE('2026-03-21', 'YYYY-MM-DD'), 7104);
  INSERT INTO PAGO VALUES (8104, 'App', 43.14, 'Pagado', TO_DATE('2026-02-07', 'YYYY-MM-DD'), 7105);
  INSERT INTO PAGO VALUES (8105, 'App', 235.71, 'Pagado', TO_DATE('2026-01-13', 'YYYY-MM-DD'), 7106);
  INSERT INTO PAGO VALUES (8106, 'Transferencia', 218.29, 'Pagado', TO_DATE('2026-01-07', 'YYYY-MM-DD'), 7107);
  INSERT INTO PAGO VALUES (8107, 'Transferencia', 147.94, 'Pagado', TO_DATE('2026-01-26', 'YYYY-MM-DD'), 7108);
  INSERT INTO PAGO VALUES (8108, 'Transferencia', 215.94, 'Pagado', TO_DATE('2026-03-22', 'YYYY-MM-DD'), 7109);
  INSERT INTO PAGO VALUES (8109, 'QR', 197.93, 'Pagado', TO_DATE('2026-03-13', 'YYYY-MM-DD'), 7110);
  INSERT INTO PAGO VALUES (8110, 'Tarjeta', 232.51, 'Pagado', TO_DATE('2026-01-18', 'YYYY-MM-DD'), 7111);
  INSERT INTO PAGO VALUES (8111, 'QR', 78.00, 'Pendiente', TO_DATE('2026-02-02', 'YYYY-MM-DD'), 7112);
  INSERT INTO PAGO VALUES (8112, 'Efectivo', 117.66, 'Pagado', TO_DATE('2026-04-08', 'YYYY-MM-DD'), 7113);
  INSERT INTO PAGO VALUES (8113, 'Efectivo', 252.45, 'Pagado', TO_DATE('2026-01-10', 'YYYY-MM-DD'), 7114);
  INSERT INTO PAGO VALUES (8114, 'App', 137.11, 'Pagado', TO_DATE('2026-01-09', 'YYYY-MM-DD'), 7115);
  INSERT INTO PAGO VALUES (8115, 'Transferencia', 168.29, 'Pendiente', TO_DATE('2026-01-29', 'YYYY-MM-DD'), 7116);
  INSERT INTO PAGO VALUES (8116, 'Tarjeta', 105.85, 'Pagado', TO_DATE('2026-03-08', 'YYYY-MM-DD'), 7117);
  INSERT INTO PAGO VALUES (8117, 'App', 200.09, 'Pagado', TO_DATE('2026-02-10', 'YYYY-MM-DD'), 7118);
  INSERT INTO PAGO VALUES (8118, 'Transferencia', 137.08, 'Pagado', TO_DATE('2026-01-05', 'YYYY-MM-DD'), 7119);
  INSERT INTO PAGO VALUES (8119, 'Transferencia', 264.21, 'Pagado', TO_DATE('2026-03-25', 'YYYY-MM-DD'), 7120);
  INSERT INTO PAGO VALUES (8120, 'Efectivo', 253.06, 'Pendiente', TO_DATE('2026-02-19', 'YYYY-MM-DD'), 7121);
  INSERT INTO PAGO VALUES (8121, 'QR', 109.00, 'Pagado', TO_DATE('2026-02-05', 'YYYY-MM-DD'), 7122);
  INSERT INTO PAGO VALUES (8122, 'App', 125.92, 'Pendiente', TO_DATE('2026-04-19', 'YYYY-MM-DD'), 7123);
  INSERT INTO PAGO VALUES (8123, 'Tarjeta', 199.36, 'Pagado', TO_DATE('2026-01-17', 'YYYY-MM-DD'), 7124);
  INSERT INTO PAGO VALUES (8124, 'App', 66.02, 'Pagado', TO_DATE('2026-04-26', 'YYYY-MM-DD'), 7125);
  INSERT INTO PAGO VALUES (8125, 'QR', 64.51, 'Pagado', TO_DATE('2026-01-10', 'YYYY-MM-DD'), 7126);
  INSERT INTO PAGO VALUES (8126, 'App', 142.46, 'Pagado', TO_DATE('2026-04-23', 'YYYY-MM-DD'), 7127);
  INSERT INTO PAGO VALUES (8127, 'App', 193.59, 'Pendiente', TO_DATE('2026-02-05', 'YYYY-MM-DD'), 7128);
  INSERT INTO PAGO VALUES (8128, 'App', 41.99, 'Pagado', TO_DATE('2026-01-26', 'YYYY-MM-DD'), 7129);
  INSERT INTO PAGO VALUES (8129, 'App', 91.04, 'Pagado', TO_DATE('2026-02-22', 'YYYY-MM-DD'), 7130);
  INSERT INTO PAGO VALUES (8130, 'Tarjeta', 58.44, 'Reembolsado', TO_DATE('2026-02-07', 'YYYY-MM-DD'), 7131);
  INSERT INTO PAGO VALUES (8131, 'Transferencia', 58.94, 'Pagado', TO_DATE('2026-02-18', 'YYYY-MM-DD'), 7132);
  INSERT INTO PAGO VALUES (8132, 'Tarjeta', 157.68, 'Pagado', TO_DATE('2026-01-07', 'YYYY-MM-DD'), 7133);
  INSERT INTO PAGO VALUES (8133, 'Tarjeta', 163.74, 'Pagado', TO_DATE('2026-02-25', 'YYYY-MM-DD'), 7134);
  INSERT INTO PAGO VALUES (8134, 'App', 236.58, 'Pagado', TO_DATE('2026-02-28', 'YYYY-MM-DD'), 7135);
  INSERT INTO PAGO VALUES (8135, 'QR', 49.70, 'Pagado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7136);
  INSERT INTO PAGO VALUES (8136, 'Transferencia', 229.82, 'Pagado', TO_DATE('2026-01-24', 'YYYY-MM-DD'), 7137);
  INSERT INTO PAGO VALUES (8137, 'QR', 241.02, 'Reembolsado', TO_DATE('2026-04-28', 'YYYY-MM-DD'), 7138);
  INSERT INTO PAGO VALUES (8138, 'QR', 66.59, 'Pagado', TO_DATE('2026-02-03', 'YYYY-MM-DD'), 7139);
  INSERT INTO PAGO VALUES (8139, 'Tarjeta', 101.91, 'Pagado', TO_DATE('2026-04-26', 'YYYY-MM-DD'), 7140);
  INSERT INTO PAGO VALUES (8140, 'QR', 164.78, 'Pagado', TO_DATE('2026-02-21', 'YYYY-MM-DD'), 7141);
  INSERT INTO PAGO VALUES (8141, 'App', 48.74, 'Pagado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7142);
  INSERT INTO PAGO VALUES (8142, 'Tarjeta', 262.92, 'Pagado', TO_DATE('2026-04-22', 'YYYY-MM-DD'), 7143);
  INSERT INTO PAGO VALUES (8143, 'App', 178.93, 'Pendiente', TO_DATE('2026-04-05', 'YYYY-MM-DD'), 7144);
  INSERT INTO PAGO VALUES (8144, 'App', 101.84, 'Pagado', TO_DATE('2026-02-21', 'YYYY-MM-DD'), 7145);
  INSERT INTO PAGO VALUES (8145, 'Transferencia', 142.00, 'Pagado', TO_DATE('2026-03-12', 'YYYY-MM-DD'), 7146);
  INSERT INTO PAGO VALUES (8146, 'QR', 147.96, 'Pagado', TO_DATE('2026-03-10', 'YYYY-MM-DD'), 7147);
  INSERT INTO PAGO VALUES (8147, 'QR', 129.38, 'Pagado', TO_DATE('2026-01-19', 'YYYY-MM-DD'), 7148);
  INSERT INTO PAGO VALUES (8148, 'App', 115.85, 'Pagado', TO_DATE('2026-04-14', 'YYYY-MM-DD'), 7149);
  INSERT INTO PAGO VALUES (8149, 'QR', 257.81, 'Pagado', TO_DATE('2026-01-14', 'YYYY-MM-DD'), 7150);
  INSERT INTO PAGO VALUES (8150, 'Tarjeta', 211.50, 'Pendiente', TO_DATE('2026-03-11', 'YYYY-MM-DD'), 7151);
  INSERT INTO PAGO VALUES (8151, 'QR', 267.68, 'Pagado', TO_DATE('2026-04-26', 'YYYY-MM-DD'), 7152);
  INSERT INTO PAGO VALUES (8152, 'QR', 210.44, 'Pagado', TO_DATE('2026-04-22', 'YYYY-MM-DD'), 7153);
  INSERT INTO PAGO VALUES (8153, 'QR', 35.64, 'Pagado', TO_DATE('2026-04-15', 'YYYY-MM-DD'), 7154);
  INSERT INTO PAGO VALUES (8154, 'Tarjeta', 135.12, 'Pagado', TO_DATE('2026-04-11', 'YYYY-MM-DD'), 7155);
  INSERT INTO PAGO VALUES (8155, 'Tarjeta', 219.70, 'Pagado', TO_DATE('2026-04-11', 'YYYY-MM-DD'), 7156);
  INSERT INTO PAGO VALUES (8156, 'Tarjeta', 259.24, 'Pagado', TO_DATE('2026-03-15', 'YYYY-MM-DD'), 7157);
  INSERT INTO PAGO VALUES (8157, 'QR', 173.92, 'Pendiente', TO_DATE('2026-03-28', 'YYYY-MM-DD'), 7158);
  INSERT INTO PAGO VALUES (8158, 'App', 218.94, 'Pagado', TO_DATE('2026-04-25', 'YYYY-MM-DD'), 7159);
  INSERT INTO PAGO VALUES (8159, 'App', 228.36, 'Pagado', TO_DATE('2026-03-22', 'YYYY-MM-DD'), 7160);
  INSERT INTO PAGO VALUES (8160, 'Efectivo', 219.06, 'Pendiente', TO_DATE('2026-03-09', 'YYYY-MM-DD'), 7161);
  INSERT INTO PAGO VALUES (8161, 'App', 48.89, 'Pagado', TO_DATE('2026-02-10', 'YYYY-MM-DD'), 7162);
  INSERT INTO PAGO VALUES (8162, 'Transferencia', 145.03, 'Pagado', TO_DATE('2026-04-10', 'YYYY-MM-DD'), 7163);
  INSERT INTO PAGO VALUES (8163, 'Efectivo', 210.52, 'Pendiente', TO_DATE('2026-01-02', 'YYYY-MM-DD'), 7164);
  INSERT INTO PAGO VALUES (8164, 'Efectivo', 187.17, 'Pendiente', TO_DATE('2026-02-21', 'YYYY-MM-DD'), 7165);
  INSERT INTO PAGO VALUES (8165, 'QR', 176.88, 'Pagado', TO_DATE('2026-01-22', 'YYYY-MM-DD'), 7166);
  INSERT INTO PAGO VALUES (8166, 'App', 126.14, 'Pagado', TO_DATE('2026-04-08', 'YYYY-MM-DD'), 7167);
  INSERT INTO PAGO VALUES (8167, 'Tarjeta', 193.00, 'Rechazado', TO_DATE('2026-03-21', 'YYYY-MM-DD'), 7168);
  INSERT INTO PAGO VALUES (8168, 'Efectivo', 208.65, 'Pagado', TO_DATE('2026-01-20', 'YYYY-MM-DD'), 7169);
  INSERT INTO PAGO VALUES (8169, 'QR', 242.91, 'Pagado', TO_DATE('2026-02-19', 'YYYY-MM-DD'), 7170);
  INSERT INTO PAGO VALUES (8170, 'QR', 40.91, 'Pagado', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7171);
  INSERT INTO PAGO VALUES (8171, 'QR', 93.02, 'Pagado', TO_DATE('2026-02-03', 'YYYY-MM-DD'), 7172);
  INSERT INTO PAGO VALUES (8172, 'App', 103.44, 'Pagado', TO_DATE('2026-01-12', 'YYYY-MM-DD'), 7173);
  INSERT INTO PAGO VALUES (8173, 'QR', 151.39, 'Pagado', TO_DATE('2026-02-27', 'YYYY-MM-DD'), 7174);
  INSERT INTO PAGO VALUES (8174, 'Tarjeta', 197.02, 'Pagado', TO_DATE('2026-04-09', 'YYYY-MM-DD'), 7175);
  INSERT INTO PAGO VALUES (8175, 'QR', 82.68, 'Pagado', TO_DATE('2026-02-11', 'YYYY-MM-DD'), 7176);
  INSERT INTO PAGO VALUES (8176, 'Transferencia', 84.26, 'Pagado', TO_DATE('2026-03-17', 'YYYY-MM-DD'), 7177);
  INSERT INTO PAGO VALUES (8177, 'Tarjeta', 37.91, 'Pagado', TO_DATE('2026-02-02', 'YYYY-MM-DD'), 7178);
  INSERT INTO PAGO VALUES (8178, 'App', 41.59, 'Pagado', TO_DATE('2026-04-18', 'YYYY-MM-DD'), 7179);
  INSERT INTO PAGO VALUES (8179, 'QR', 145.83, 'Pagado', TO_DATE('2026-01-05', 'YYYY-MM-DD'), 7180);
  INSERT INTO PAGO VALUES (8180, 'Transferencia', 194.71, 'Pagado', TO_DATE('2026-01-02', 'YYYY-MM-DD'), 7181);
  INSERT INTO PAGO VALUES (8181, 'Transferencia', 217.30, 'Pendiente', TO_DATE('2026-01-25', 'YYYY-MM-DD'), 7182);
  INSERT INTO PAGO VALUES (8182, 'App', 199.21, 'Pagado', TO_DATE('2026-01-28', 'YYYY-MM-DD'), 7183);
  INSERT INTO PAGO VALUES (8183, 'Tarjeta', 148.87, 'Pagado', TO_DATE('2026-03-11', 'YYYY-MM-DD'), 7184);
  INSERT INTO PAGO VALUES (8184, 'QR', 101.42, 'Pagado', TO_DATE('2026-01-09', 'YYYY-MM-DD'), 7185);
  INSERT INTO PAGO VALUES (8185, 'Transferencia', 212.76, 'Pagado', TO_DATE('2026-02-18', 'YYYY-MM-DD'), 7186);
  INSERT INTO PAGO VALUES (8186, 'Tarjeta', 85.96, 'Pagado', TO_DATE('2026-01-07', 'YYYY-MM-DD'), 7187);
  INSERT INTO PAGO VALUES (8187, 'Efectivo', 135.93, 'Pagado', TO_DATE('2026-01-31', 'YYYY-MM-DD'), 7188);
  INSERT INTO PAGO VALUES (8188, 'App', 48.78, 'Pagado', TO_DATE('2026-03-28', 'YYYY-MM-DD'), 7189);
  INSERT INTO PAGO VALUES (8189, 'QR', 91.25, 'Pagado', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7190);
  INSERT INTO PAGO VALUES (8190, 'Tarjeta', 105.92, 'Reembolsado', TO_DATE('2026-04-19', 'YYYY-MM-DD'), 7191);
  INSERT INTO PAGO VALUES (8191, 'Transferencia', 161.58, 'Pagado', TO_DATE('2026-01-28', 'YYYY-MM-DD'), 7192);
  INSERT INTO PAGO VALUES (8192, 'Efectivo', 252.76, 'Pagado', TO_DATE('2026-01-23', 'YYYY-MM-DD'), 7193);
  INSERT INTO PAGO VALUES (8193, 'Tarjeta', 82.22, 'Pagado', TO_DATE('2026-02-10', 'YYYY-MM-DD'), 7194);
  INSERT INTO PAGO VALUES (8194, 'Transferencia', 112.61, 'Pagado', TO_DATE('2026-03-26', 'YYYY-MM-DD'), 7195);
  INSERT INTO PAGO VALUES (8195, 'Tarjeta', 50.26, 'Pagado', TO_DATE('2026-03-05', 'YYYY-MM-DD'), 7196);
  INSERT INTO PAGO VALUES (8196, 'QR', 44.38, 'Pagado', TO_DATE('2026-04-21', 'YYYY-MM-DD'), 7197);
  INSERT INTO PAGO VALUES (8197, 'Transferencia', 259.60, 'Pagado', TO_DATE('2026-04-25', 'YYYY-MM-DD'), 7198);
  INSERT INTO PAGO VALUES (8198, 'Tarjeta', 79.64, 'Pagado', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7199);
  INSERT INTO PAGO VALUES (8199, 'Transferencia', 103.65, 'Pagado', TO_DATE('2026-04-11', 'YYYY-MM-DD'), 7200);
  INSERT INTO PAGO VALUES (8200, 'QR', 235.26, 'Pagado', TO_DATE('2026-03-09', 'YYYY-MM-DD'), 7201);
  COMMIT;
END;

--bloque 3
BEGIN
  INSERT INTO PAGO VALUES (8201, 'Efectivo', 156.40, 'Rechazado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7181);
  INSERT INTO PAGO VALUES (8202, 'Tarjeta', 57.06, 'Pagado', TO_DATE('2026-02-14', 'YYYY-MM-DD'), 7182);
  INSERT INTO PAGO VALUES (8203, 'Transferencia', 87.05, 'Rechazado', TO_DATE('2026-04-18', 'YYYY-MM-DD'), 7183);
  INSERT INTO PAGO VALUES (8204, 'Tarjeta', 211.59, 'Rechazado', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7184);
  INSERT INTO PAGO VALUES (8205, 'Tarjeta', 230.12, 'Pagado', TO_DATE('2026-01-20', 'YYYY-MM-DD'), 7185);
  INSERT INTO PAGO VALUES (8206, 'App', 101.40, 'Pagado', TO_DATE('2026-04-06', 'YYYY-MM-DD'), 7186);
  INSERT INTO PAGO VALUES (8207, 'Transferencia', 105.85, 'Pagado', TO_DATE('2026-02-04', 'YYYY-MM-DD'), 7187);
  INSERT INTO PAGO VALUES (8208, 'QR', 198.88, 'Pagado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7188);
  INSERT INTO PAGO VALUES (8209, 'Tarjeta', 133.02, 'Pagado', TO_DATE('2026-03-09', 'YYYY-MM-DD'), 7189);
  INSERT INTO PAGO VALUES (8210, 'QR', 95.88, 'Pagado', TO_DATE('2026-03-09', 'YYYY-MM-DD'), 7189);
  INSERT INTO PAGO VALUES (8211, 'App', 178.68, 'Rechazado', TO_DATE('2026-04-28', 'YYYY-MM-DD'), 7190);
  INSERT INTO PAGO VALUES (8212, 'Tarjeta', 101.99, 'Reembolsado', TO_DATE('2026-02-18', 'YYYY-MM-DD'), 7191);
  INSERT INTO PAGO VALUES (8213, 'Transferencia', 123.63, 'Pagado', TO_DATE('2026-02-25', 'YYYY-MM-DD'), 7192);
  INSERT INTO PAGO VALUES (8214, 'Tarjeta', 201.25, 'Pagado', TO_DATE('2026-02-06', 'YYYY-MM-DD'), 7193);
  INSERT INTO PAGO VALUES (8215, 'Tarjeta', 133.40, 'Pendiente', TO_DATE('2026-01-22', 'YYYY-MM-DD'), 7194);
  INSERT INTO PAGO VALUES (8216, 'App', 231.28, 'Pagado', TO_DATE('2026-04-27', 'YYYY-MM-DD'), 7195);
  INSERT INTO PAGO VALUES (8217, 'Transferencia', 133.15, 'Rechazado', TO_DATE('2026-03-08', 'YYYY-MM-DD'), 7196);
  INSERT INTO PAGO VALUES (8218, 'Tarjeta', 159.04, 'Rechazado', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7197);
  INSERT INTO PAGO VALUES (8219, 'QR', 221.72, 'Rechazado', TO_DATE('2026-02-17', 'YYYY-MM-DD'), 7198);
  INSERT INTO PAGO VALUES (8220, 'Efectivo', 164.73, 'Pagado', TO_DATE('2026-03-07', 'YYYY-MM-DD'), 7199);
  INSERT INTO PAGO VALUES (8221, 'Efectivo', 190.28, 'Pagado', TO_DATE('2026-04-27', 'YYYY-MM-DD'), 7200);
  INSERT INTO PAGO VALUES (8222, 'Tarjeta', 151.78, 'Reembolsado', TO_DATE('2026-02-24', 'YYYY-MM-DD'), 7201);
  INSERT INTO PAGO VALUES (8223, 'Efectivo', 123.63, 'Pagado', TO_DATE('2026-03-10', 'YYYY-MM-DD'), 7202);
  INSERT INTO PAGO VALUES (8224, 'App', 170.83, 'Pagado', TO_DATE('2026-02-14', 'YYYY-MM-DD'), 7203);
  INSERT INTO PAGO VALUES (8225, 'Efectivo', 165.71, 'Pagado', TO_DATE('2026-01-26', 'YYYY-MM-DD'), 7204);
  INSERT INTO PAGO VALUES (8226, 'Transferencia', 64.91, 'Rechazado', TO_DATE('2026-04-27', 'YYYY-MM-DD'), 7205);
  INSERT INTO PAGO VALUES (8227, 'App', 44.82, 'Reembolsado', TO_DATE('2026-01-16', 'YYYY-MM-DD'), 7206);
  INSERT INTO PAGO VALUES (8228, 'Efectivo', 119.26, 'Pagado', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7207);
  INSERT INTO PAGO VALUES (8229, 'QR', 213.16, 'Pendiente', TO_DATE('2026-03-13', 'YYYY-MM-DD'), 7208);
  INSERT INTO PAGO VALUES (8230, 'App', 51.72, 'Pagado', TO_DATE('2026-04-14', 'YYYY-MM-DD'), 7209);
  INSERT INTO PAGO VALUES (8231, 'Transferencia', 58.74, 'Rechazado', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7210);
  INSERT INTO PAGO VALUES (8232, 'Efectivo', 232.06, 'Pendiente', TO_DATE('2026-02-15', 'YYYY-MM-DD'), 7211);
  INSERT INTO PAGO VALUES (8233, 'App', 43.14, 'Pagado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7212);
  INSERT INTO PAGO VALUES (8234, 'Transferencia', 235.71, 'Rechazado', TO_DATE('2026-01-11', 'YYYY-MM-DD'), 7213);
  INSERT INTO PAGO VALUES (8235, 'Transferencia', 218.29, 'Pendiente', TO_DATE('2026-01-14', 'YYYY-MM-DD'), 7214);
  INSERT INTO PAGO VALUES (8236, 'Tarjeta', 147.94, 'Reembolsado', TO_DATE('2026-01-05', 'YYYY-MM-DD'), 7215);
  INSERT INTO PAGO VALUES (8237, 'QR', 103.57, 'Rechazado', TO_DATE('2026-02-03', 'YYYY-MM-DD'), 7216);
  INSERT INTO PAGO VALUES (8238, 'Efectivo', 246.97, 'Pagado', TO_DATE('2026-03-08', 'YYYY-MM-DD'), 7217);
  INSERT INTO PAGO VALUES (8239, 'Tarjeta', 133.00, 'Pagado', TO_DATE('2026-03-14', 'YYYY-MM-DD'), 7218);
  INSERT INTO PAGO VALUES (8240, 'QR', 64.93, 'Pagado', TO_DATE('2026-03-14', 'YYYY-MM-DD'), 7218);
  INSERT INTO PAGO VALUES (8241, 'Transferencia', 261.97, 'Pendiente', TO_DATE('2026-02-16', 'YYYY-MM-DD'), 7219);
  INSERT INTO PAGO VALUES (8242, 'Transferencia', 238.97, 'Pagado', TO_DATE('2026-01-20', 'YYYY-MM-DD'), 7220);
  INSERT INTO PAGO VALUES (8243, 'QR', 99.39, 'Pagado', TO_DATE('2026-04-18', 'YYYY-MM-DD'), 7221);
  INSERT INTO PAGO VALUES (8244, 'Transferencia', 216.06, 'Pagado', TO_DATE('2026-04-16', 'YYYY-MM-DD'), 7222);
  INSERT INTO PAGO VALUES (8245, 'QR', 109.95, 'Pendiente', TO_DATE('2026-04-10', 'YYYY-MM-DD'), 7223);
  INSERT INTO PAGO VALUES (8246, 'Efectivo', 180.77, 'Pagado', TO_DATE('2026-02-12', 'YYYY-MM-DD'), 7224);
  INSERT INTO PAGO VALUES (8247, 'Efectivo', 242.89, 'Pagado', TO_DATE('2026-02-14', 'YYYY-MM-DD'), 7225);
  INSERT INTO PAGO VALUES (8248, 'QR', 107.19, 'Rechazado', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7226);
  INSERT INTO PAGO VALUES (8249, 'Tarjeta', 203.12, 'Pagado', TO_DATE('2026-01-21', 'YYYY-MM-DD'), 7227);
  INSERT INTO PAGO VALUES (8250, 'QR', 219.07, 'Rechazado', TO_DATE('2026-02-11', 'YYYY-MM-DD'), 7228);
  INSERT INTO PAGO VALUES (8251, 'Efectivo', 196.01, 'Pendiente', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7229);
  INSERT INTO PAGO VALUES (8252, 'App', 221.76, 'Pendiente', TO_DATE('2026-04-03', 'YYYY-MM-DD'), 7230);
  INSERT INTO PAGO VALUES (8253, 'Tarjeta', 164.56, 'Reembolsado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7231);
  INSERT INTO PAGO VALUES (8254, 'Efectivo', 230.18, 'Rechazado', TO_DATE('2026-01-29', 'YYYY-MM-DD'), 7232);
  INSERT INTO PAGO VALUES (8255, 'QR', 219.55, 'Pagado', TO_DATE('2026-02-16', 'YYYY-MM-DD'), 7233);
  INSERT INTO PAGO VALUES (8256, 'Tarjeta', 94.79, 'Pagado', TO_DATE('2026-03-12', 'YYYY-MM-DD'), 7234);
  INSERT INTO PAGO VALUES (8257, 'Efectivo', 195.29, 'Pagado', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7235);
  INSERT INTO PAGO VALUES (8258, 'App', 252.56, 'Pagado', TO_DATE('2026-03-08', 'YYYY-MM-DD'), 7236);
  INSERT INTO PAGO VALUES (8259, 'Efectivo', 131.92, 'Pagado', TO_DATE('2026-01-01', 'YYYY-MM-DD'), 7237);
  INSERT INTO PAGO VALUES (8260, 'Transferencia', 232.01, 'Pagado', TO_DATE('2026-02-10', 'YYYY-MM-DD'), 7238);
  INSERT INTO PAGO VALUES (8261, 'QR', 134.19, 'Pagado', TO_DATE('2026-01-28', 'YYYY-MM-DD'), 7239);
  INSERT INTO PAGO VALUES (8262, 'Efectivo', 97.20, 'Pagado', TO_DATE('2026-03-12', 'YYYY-MM-DD'), 7240);
  INSERT INTO PAGO VALUES (8263, 'App', 236.75, 'Rechazado', TO_DATE('2026-01-30', 'YYYY-MM-DD'), 7241);
  INSERT INTO PAGO VALUES (8264, 'QR', 129.10, 'Pendiente', TO_DATE('2026-01-14', 'YYYY-MM-DD'), 7242);
  INSERT INTO PAGO VALUES (8265, 'Tarjeta', 51.51, 'Pendiente', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7243);
  INSERT INTO PAGO VALUES (8266, 'Efectivo', 59.39, 'Pagado', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7244);
  INSERT INTO PAGO VALUES (8267, 'App', 185.96, 'Pagado', TO_DATE('2026-01-29', 'YYYY-MM-DD'), 7245);
  INSERT INTO PAGO VALUES (8268, 'App', 190.66, 'Pagado', TO_DATE('2026-02-07', 'YYYY-MM-DD'), 7246);
  INSERT INTO PAGO VALUES (8269, 'Efectivo', 152.24, 'Pagado', TO_DATE('2026-04-10', 'YYYY-MM-DD'), 7247);
  INSERT INTO PAGO VALUES (8270, 'QR', 212.83, 'Pagado', TO_DATE('2026-01-13', 'YYYY-MM-DD'), 7248);
  INSERT INTO PAGO VALUES (8271, 'Tarjeta', 229.03, 'Rechazado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7249);
  INSERT INTO PAGO VALUES (8272, 'App', 177.81, 'Pagado', TO_DATE('2026-01-19', 'YYYY-MM-DD'), 7250);
  INSERT INTO PAGO VALUES (8273, 'App', 183.57, 'Rechazado', TO_DATE('2026-02-03', 'YYYY-MM-DD'), 7251);
  INSERT INTO PAGO VALUES (8274, 'Tarjeta', 83.71, 'Pagado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7252);
  INSERT INTO PAGO VALUES (8275, 'App', 100.93, 'Pagado', TO_DATE('2026-03-08', 'YYYY-MM-DD'), 7253);
  INSERT INTO PAGO VALUES (8276, 'Transferencia', 246.28, 'Pagado', TO_DATE('2026-02-18', 'YYYY-MM-DD'), 7254);
  INSERT INTO PAGO VALUES (8277, 'Transferencia', 139.32, 'Pendiente', TO_DATE('2026-03-09', 'YYYY-MM-DD'), 7255);
  INSERT INTO PAGO VALUES (8278, 'Transferencia', 110.96, 'Rechazado', TO_DATE('2026-03-12', 'YYYY-MM-DD'), 7256);
  INSERT INTO PAGO VALUES (8279, 'App', 50.43, 'Rechazado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7257);
  INSERT INTO PAGO VALUES (8280, 'Efectivo', 139.54, 'Pagado', TO_DATE('2026-02-25', 'YYYY-MM-DD'), 7258);
  INSERT INTO PAGO VALUES (8281, 'Efectivo', 127.80, 'Pagado', TO_DATE('2026-02-14', 'YYYY-MM-DD'), 7259);
  INSERT INTO PAGO VALUES (8282, 'Efectivo', 212.95, 'Pendiente', TO_DATE('2026-04-19', 'YYYY-MM-DD'), 7260);
  INSERT INTO PAGO VALUES (8283, 'Tarjeta', 173.00, 'Pendiente', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7261);
  INSERT INTO PAGO VALUES (8284, 'Transferencia', 163.21, 'Pagado', TO_DATE('2026-01-20', 'YYYY-MM-DD'), 7262);
  INSERT INTO PAGO VALUES (8285, 'QR', 75.87, 'Pendiente', TO_DATE('2026-03-08', 'YYYY-MM-DD'), 7263);
  INSERT INTO PAGO VALUES (8286, 'Efectivo', 186.72, 'Pagado', TO_DATE('2026-02-21', 'YYYY-MM-DD'), 7264);
  INSERT INTO PAGO VALUES (8287, 'Transferencia', 139.02, 'Pendiente', TO_DATE('2026-04-19', 'YYYY-MM-DD'), 7265);
  INSERT INTO PAGO VALUES (8288, 'Transferencia', 235.89, 'Rechazado', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7266);
  INSERT INTO PAGO VALUES (8289, 'Efectivo', 98.33, 'Pagado', TO_DATE('2026-04-21', 'YYYY-MM-DD'), 7267);
  INSERT INTO PAGO VALUES (8290, 'Tarjeta', 205.19, 'Reembolsado', TO_DATE('2026-04-18', 'YYYY-MM-DD'), 7268);
  INSERT INTO PAGO VALUES (8291, 'App', 65.45, 'Pagado', TO_DATE('2026-04-06', 'YYYY-MM-DD'), 7269);
  INSERT INTO PAGO VALUES (8292, 'Tarjeta', 153.01, 'Rechazado', TO_DATE('2026-01-01', 'YYYY-MM-DD'), 7270);
  INSERT INTO PAGO VALUES (8293, 'Tarjeta', 111.25, 'Pagado', TO_DATE('2026-04-06', 'YYYY-MM-DD'), 7271);
  INSERT INTO PAGO VALUES (8294, 'Efectivo', 97.32, 'Pagado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7272);
  INSERT INTO PAGO VALUES (8295, 'Tarjeta', 70.36, 'Reembolsado', TO_DATE('2026-01-04', 'YYYY-MM-DD'), 7273);
  INSERT INTO PAGO VALUES (8296, 'Tarjeta', 84.64, 'Pagado', TO_DATE('2026-03-10', 'YYYY-MM-DD'), 7274);
  INSERT INTO PAGO VALUES (8297, 'Efectivo', 178.36, 'Pendiente', TO_DATE('2026-02-14', 'YYYY-MM-DD'), 7275);
  INSERT INTO PAGO VALUES (8298, 'Transferencia', 174.01, 'Pagado', TO_DATE('2026-03-21', 'YYYY-MM-DD'), 7276);
  INSERT INTO PAGO VALUES (8299, 'Tarjeta', 66.59, 'Pagado', TO_DATE('2026-04-15', 'YYYY-MM-DD'), 7277);
  INSERT INTO PAGO VALUES (8300, 'Tarjeta', 54.17, 'Pendiente', TO_DATE('2026-03-22', 'YYYY-MM-DD'), 7278);
  COMMIT;
END;

--bloque 4 
BEGIN
  INSERT INTO PAGO VALUES (8301, 'Transferencia', 210.61, 'Pagado', TO_DATE('2026-04-14', 'YYYY-MM-DD'), 7279);
  INSERT INTO PAGO VALUES (8302, 'Efectivo', 123.14, 'Pagado', TO_DATE('2026-02-12', 'YYYY-MM-DD'), 7280);
  INSERT INTO PAGO VALUES (8303, 'Tarjeta', 169.80, 'Pagado', TO_DATE('2026-01-26', 'YYYY-MM-DD'), 7281);
  INSERT INTO PAGO VALUES (8304, 'Transferencia', 235.47, 'Pagado', TO_DATE('2026-02-05', 'YYYY-MM-DD'), 7282);
  INSERT INTO PAGO VALUES (8305, 'Transferencia', 96.27, 'Rechazado', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7283);
  INSERT INTO PAGO VALUES (8306, 'Efectivo', 233.08, 'Pendiente', TO_DATE('2026-02-27', 'YYYY-MM-DD'), 7284);
  INSERT INTO PAGO VALUES (8307, 'Transferencia', 161.87, 'Rechazado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7285);
  INSERT INTO PAGO VALUES (8308, 'QR', 179.67, 'Pagado', TO_DATE('2026-01-13', 'YYYY-MM-DD'), 7286);
  INSERT INTO PAGO VALUES (8309, 'QR', 38.09, 'Rechazado', TO_DATE('2026-04-21', 'YYYY-MM-DD'), 7287);
  INSERT INTO PAGO VALUES (8310, 'App', 232.32, 'Pendiente', TO_DATE('2026-02-03', 'YYYY-MM-DD'), 7288);
  INSERT INTO PAGO VALUES (8311, 'App', 200.80, 'Rechazado', TO_DATE('2026-03-09', 'YYYY-MM-DD'), 7289);
  INSERT INTO PAGO VALUES (8312, 'QR', 127.85, 'Pagado', TO_DATE('2026-01-15', 'YYYY-MM-DD'), 7290);
  INSERT INTO PAGO VALUES (8313, 'Transferencia', 192.47, 'Rechazado', TO_DATE('2026-01-27', 'YYYY-MM-DD'), 7291);
  INSERT INTO PAGO VALUES (8314, 'QR', 156.77, 'Rechazado', TO_DATE('2026-04-09', 'YYYY-MM-DD'), 7292);
  INSERT INTO PAGO VALUES (8315, 'App', 161.67, 'Pagado', TO_DATE('2026-04-24', 'YYYY-MM-DD'), 7293);
  INSERT INTO PAGO VALUES (8316, 'Efectivo', 202.96, 'Pagado', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7294);
  INSERT INTO PAGO VALUES (8317, 'Tarjeta', 182.43, 'Rechazado', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7295);
  INSERT INTO PAGO VALUES (8318, 'App', 157.29, 'Pendiente', TO_DATE('2026-04-14', 'YYYY-MM-DD'), 7296);
  INSERT INTO PAGO VALUES (8319, 'Transferencia', 126.79, 'Pagado', TO_DATE('2026-03-04', 'YYYY-MM-DD'), 7297);
  INSERT INTO PAGO VALUES (8320, 'Efectivo', 123.15, 'Pendiente', TO_DATE('2026-02-22', 'YYYY-MM-DD'), 7298);
  INSERT INTO PAGO VALUES (8321, 'App', 176.30, 'Pagado', TO_DATE('2026-02-12', 'YYYY-MM-DD'), 7299);
  INSERT INTO PAGO VALUES (8322, 'Tarjeta', 66.27, 'Pagado', TO_DATE('2026-03-12', 'YYYY-MM-DD'), 7300);
  INSERT INTO PAGO VALUES (8323, 'Transferencia', 62.07, 'Pendiente', TO_DATE('2026-01-29', 'YYYY-MM-DD'), 7301);
  INSERT INTO PAGO VALUES (8324, 'App', 232.90, 'Pagado', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7302);
  INSERT INTO PAGO VALUES (8325, 'Tarjeta', 177.99, 'Rechazado', TO_DATE('2026-03-16', 'YYYY-MM-DD'), 7303);
  INSERT INTO PAGO VALUES (8326, 'Efectivo', 94.14, 'Pagado', TO_DATE('2026-03-01', 'YYYY-MM-DD'), 7304);
  INSERT INTO PAGO VALUES (8327, 'Tarjeta', 138.58, 'Pendiente', TO_DATE('2026-01-16', 'YYYY-MM-DD'), 7305);
  INSERT INTO PAGO VALUES (8328, 'QR', 247.20, 'Pendiente', TO_DATE('2026-03-08', 'YYYY-MM-DD'), 7306);
  INSERT INTO PAGO VALUES (8329, 'Efectivo', 240.70, 'Pagado', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7307);
  INSERT INTO PAGO VALUES (8330, 'Efectivo', 84.18, 'Rechazado', TO_DATE('2026-04-26', 'YYYY-MM-DD'), 7308);
  INSERT INTO PAGO VALUES (8331, 'QR', 196.68, 'Reembolsado', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7309);
  INSERT INTO PAGO VALUES (8332, 'Tarjeta', 45.62, 'Pagado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7310);
  INSERT INTO PAGO VALUES (8333, 'App', 124.87, 'Pagado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7311);
  INSERT INTO PAGO VALUES (8334, 'Efectivo', 62.36, 'Reembolsado', TO_DATE('2026-04-18', 'YYYY-MM-DD'), 7312);
  INSERT INTO PAGO VALUES (8335, 'Transferencia', 125.44, 'Pendiente', TO_DATE('2026-04-11', 'YYYY-MM-DD'), 7313);
  INSERT INTO PAGO VALUES (8336, 'Efectivo', 118.86, 'Pagado', TO_DATE('2026-04-21', 'YYYY-MM-DD'), 7314);
  INSERT INTO PAGO VALUES (8337, 'Efectivo', 219.70, 'Pagado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7315);
  INSERT INTO PAGO VALUES (8338, 'App', 259.24, 'Pagado', TO_DATE('2026-01-14', 'YYYY-MM-DD'), 7316);
  INSERT INTO PAGO VALUES (8339, 'Transferencia', 233.94, 'Rechazado', TO_DATE('2026-01-19', 'YYYY-MM-DD'), 7317);
  INSERT INTO PAGO VALUES (8340, 'Efectivo', 260.28, 'Pagado', TO_DATE('2026-01-20', 'YYYY-MM-DD'), 7318);
  INSERT INTO PAGO VALUES (8341, 'Transferencia', 216.51, 'Pagado', TO_DATE('2026-01-27', 'YYYY-MM-DD'), 7319);
  INSERT INTO PAGO VALUES (8342, 'Transferencia', 242.59, 'Pagado', TO_DATE('2026-04-24', 'YYYY-MM-DD'), 7320);
  INSERT INTO PAGO VALUES (8343, 'App', 222.93, 'Pendiente', TO_DATE('2026-04-09', 'YYYY-MM-DD'), 7321);
  INSERT INTO PAGO VALUES (8344, 'App', 232.82, 'Rechazado', TO_DATE('2026-01-21', 'YYYY-MM-DD'), 7322);
  INSERT INTO PAGO VALUES (8345, 'Tarjeta', 88.62, 'Pagado', TO_DATE('2026-01-11', 'YYYY-MM-DD'), 7323);
  INSERT INTO PAGO VALUES (8346, 'Efectivo', 54.17, 'Pagado', TO_DATE('2026-04-03', 'YYYY-MM-DD'), 7324);
  INSERT INTO PAGO VALUES (8347, 'Transferencia', 212.03, 'Pagado', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7325);
  INSERT INTO PAGO VALUES (8348, 'QR', 70.03, 'Rechazado', TO_DATE('2026-04-05', 'YYYY-MM-DD'), 7326);
  INSERT INTO PAGO VALUES (8349, 'Transferencia', 129.07, 'Pendiente', TO_DATE('2026-01-29', 'YYYY-MM-DD'), 7327);
  INSERT INTO PAGO VALUES (8350, 'Tarjeta', 220.68, 'Pagado', TO_DATE('2026-01-09', 'YYYY-MM-DD'), 7328);
  INSERT INTO PAGO VALUES (8351, 'Efectivo', 56.02, 'Pagado', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7329);
  INSERT INTO PAGO VALUES (8352, 'Tarjeta', 154.73, 'Pagado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7330);
  INSERT INTO PAGO VALUES (8353, 'QR', 190.43, 'Rechazado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7331);
  INSERT INTO PAGO VALUES (8354, 'Efectivo', 135.02, 'Pagado', TO_DATE('2026-04-08', 'YYYY-MM-DD'), 7332);
  INSERT INTO PAGO VALUES (8355, 'App', 155.89, 'Rechazado', TO_DATE('2026-03-26', 'YYYY-MM-DD'), 7333);
  INSERT INTO PAGO VALUES (8356, 'QR', 135.57, 'Pagado', TO_DATE('2026-01-31', 'YYYY-MM-DD'), 7334);
  INSERT INTO PAGO VALUES (8357, 'Tarjeta', 206.54, 'Rechazado', TO_DATE('2026-01-19', 'YYYY-MM-DD'), 7335);
  INSERT INTO PAGO VALUES (8358, 'App', 158.03, 'Pagado', TO_DATE('2026-04-06', 'YYYY-MM-DD'), 7336);
  INSERT INTO PAGO VALUES (8359, 'Efectivo', 220.33, 'Pendiente', TO_DATE('2026-01-03', 'YYYY-MM-DD'), 7337);
  INSERT INTO PAGO VALUES (8360, 'Efectivo', 147.91, 'Pendiente', TO_DATE('2026-01-30', 'YYYY-MM-DD'), 7338);
  INSERT INTO PAGO VALUES (8361, 'Transferencia', 195.07, 'Pendiente', TO_DATE('2026-01-18', 'YYYY-MM-DD'), 7339);
  INSERT INTO PAGO VALUES (8362, 'Transferencia', 51.41, 'Rechazado', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7340);
  INSERT INTO PAGO VALUES (8363, 'Tarjeta', 215.86, 'Pendiente', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7341);
  INSERT INTO PAGO VALUES (8364, 'QR', 61.99, 'Reembolsado', TO_DATE('2026-03-01', 'YYYY-MM-DD'), 7342);
  INSERT INTO PAGO VALUES (8365, 'App', 143.38, 'Pendiente', TO_DATE('2026-04-22', 'YYYY-MM-DD'), 7343);
  INSERT INTO PAGO VALUES (8366, 'Efectivo', 102.27, 'Rechazado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7344);
  INSERT INTO PAGO VALUES (8367, 'Efectivo', 75.38, 'Pagado', TO_DATE('2026-04-05', 'YYYY-MM-DD'), 7345);
  INSERT INTO PAGO VALUES (8368, 'Tarjeta', 137.74, 'Rechazado', TO_DATE('2026-01-30', 'YYYY-MM-DD'), 7346);
  INSERT INTO PAGO VALUES (8369, 'QR', 192.13, 'Pendiente', TO_DATE('2026-01-25', 'YYYY-MM-DD'), 7347);
  INSERT INTO PAGO VALUES (8370, 'QR', 86.38, 'Rechazado', TO_DATE('2026-01-31', 'YYYY-MM-DD'), 7348);
  INSERT INTO PAGO VALUES (8371, 'App', 212.18, 'Pendiente', TO_DATE('2026-02-17', 'YYYY-MM-DD'), 7349);
  INSERT INTO PAGO VALUES (8372, 'Tarjeta', 109.12, 'Pendiente', TO_DATE('2026-04-18', 'YYYY-MM-DD'), 7350);
  INSERT INTO PAGO VALUES (8373, 'Tarjeta', 251.00, 'Pagado', TO_DATE('2026-03-12', 'YYYY-MM-DD'), 7351);
  INSERT INTO PAGO VALUES (8374, 'Efectivo', 118.31, 'Pendiente', TO_DATE('2026-04-12', 'YYYY-MM-DD'), 7352);
  INSERT INTO PAGO VALUES (8375, 'App', 72.52, 'Reembolsado', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7353);
  INSERT INTO PAGO VALUES (8376, 'Transferencia', 205.53, 'Pagado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7354);
  INSERT INTO PAGO VALUES (8377, 'Transferencia', 135.17, 'Pagado', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7355);
  INSERT INTO PAGO VALUES (8378, 'Tarjeta', 239.30, 'Pagado', TO_DATE('2026-03-01', 'YYYY-MM-DD'), 7356);
  INSERT INTO PAGO VALUES (8379, 'App', 139.65, 'Rechazado', TO_DATE('2026-01-22', 'YYYY-MM-DD'), 7357);
  INSERT INTO PAGO VALUES (8380, 'Transferencia', 235.80, 'Pagado', TO_DATE('2026-02-06', 'YYYY-MM-DD'), 7358);
  INSERT INTO PAGO VALUES (8381, 'QR', 162.63, 'Pendiente', TO_DATE('2026-04-06', 'YYYY-MM-DD'), 7359);
  INSERT INTO PAGO VALUES (8382, 'Efectivo', 178.06, 'Pagado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7360);
  INSERT INTO PAGO VALUES (8383, 'Efectivo', 109.72, 'Pagado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7361);
  INSERT INTO PAGO VALUES (8384, 'Efectivo', 55.45, 'Pagado', TO_DATE('2026-02-14', 'YYYY-MM-DD'), 7362);
  INSERT INTO PAGO VALUES (8385, 'QR', 143.08, 'Pagado', TO_DATE('2026-01-14', 'YYYY-MM-DD'), 7363);
  INSERT INTO PAGO VALUES (8386, 'Efectivo', 115.42, 'Pagado', TO_DATE('2026-04-09', 'YYYY-MM-DD'), 7364);
  INSERT INTO PAGO VALUES (8387, 'Transferencia', 196.21, 'Pendiente', TO_DATE('2026-04-18', 'YYYY-MM-DD'), 7365);
  INSERT INTO PAGO VALUES (8388, 'Tarjeta', 162.01, 'Pendiente', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7366);
  INSERT INTO PAGO VALUES (8389, 'App', 244.64, 'Pagado', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7367);
  INSERT INTO PAGO VALUES (8390, 'Tarjeta', 103.57, 'Rechazado', TO_DATE('2026-01-19', 'YYYY-MM-DD'), 7368);
  INSERT INTO PAGO VALUES (8391, 'App', 246.97, 'Pendiente', TO_DATE('2026-02-27', 'YYYY-MM-DD'), 7369);
  INSERT INTO PAGO VALUES (8392, 'App', 261.97, 'Pagado', TO_DATE('2026-04-22', 'YYYY-MM-DD'), 7370);
  INSERT INTO PAGO VALUES (8393, 'Tarjeta', 238.97, 'Rechazado', TO_DATE('2026-01-20', 'YYYY-MM-DD'), 7371);
  INSERT INTO PAGO VALUES (8394, 'Tarjeta', 99.39, 'Rechazado', TO_DATE('2026-01-17', 'YYYY-MM-DD'), 7372);
  INSERT INTO PAGO VALUES (8395, 'Tarjeta', 216.06, 'Rechazado', TO_DATE('2026-03-12', 'YYYY-MM-DD'), 7373);
  INSERT INTO PAGO VALUES (8396, 'Efectivo', 109.95, 'Pagado', TO_DATE('2026-02-14', 'YYYY-MM-DD'), 7374);
  INSERT INTO PAGO VALUES (8397, 'Efectivo', 180.77, 'Pagado', TO_DATE('2026-04-12', 'YYYY-MM-DD'), 7375);
  INSERT INTO PAGO VALUES (8398, 'QR', 242.89, 'Pagado', TO_DATE('2026-02-28', 'YYYY-MM-DD'), 7376);
  INSERT INTO PAGO VALUES (8399, 'Efectivo', 107.19, 'Pagado', TO_DATE('2026-01-09', 'YYYY-MM-DD'), 7377);
  INSERT INTO PAGO VALUES (8400, 'Tarjeta', 203.12, 'Pagado', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7378);
  COMMIT;
END;

--bloque 5
BEGIN
  INSERT INTO PAGO VALUES (8401, 'Transferencia', 219.07, 'Rechazado', TO_DATE('2026-02-11', 'YYYY-MM-DD'), 7379);
  INSERT INTO PAGO VALUES (8402, 'Efectivo', 196.01, 'Pendiente', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7380);
  INSERT INTO PAGO VALUES (8403, 'App', 221.76, 'Pendiente', TO_DATE('2026-04-03', 'YYYY-MM-DD'), 7381);
  INSERT INTO PAGO VALUES (8404, 'Tarjeta', 164.56, 'Reembolsado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7382);
  INSERT INTO PAGO VALUES (8405, 'Efectivo', 230.18, 'Rechazado', TO_DATE('2026-01-29', 'YYYY-MM-DD'), 7383);
  INSERT INTO PAGO VALUES (8406, 'QR', 219.55, 'Pagado', TO_DATE('2026-02-16', 'YYYY-MM-DD'), 7384);
  INSERT INTO PAGO VALUES (8407, 'Tarjeta', 94.79, 'Pagado', TO_DATE('2026-03-12', 'YYYY-MM-DD'), 7385);
  INSERT INTO PAGO VALUES (8408, 'Efectivo', 195.29, 'Pagado', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7386);
  INSERT INTO PAGO VALUES (8409, 'App', 252.56, 'Pagado', TO_DATE('2026-03-08', 'YYYY-MM-DD'), 7387);
  INSERT INTO PAGO VALUES (8410, 'Efectivo', 131.92, 'Pagado', TO_DATE('2026-01-01', 'YYYY-MM-DD'), 7388);
  INSERT INTO PAGO VALUES (8411, 'Transferencia', 232.01, 'Pagado', TO_DATE('2026-02-10', 'YYYY-MM-DD'), 7389);
  INSERT INTO PAGO VALUES (8412, 'QR', 134.19, 'Pagado', TO_DATE('2026-01-28', 'YYYY-MM-DD'), 7390);
  INSERT INTO PAGO VALUES (8413, 'Efectivo', 97.20, 'Pagado', TO_DATE('2026-03-12', 'YYYY-MM-DD'), 7391);
  INSERT INTO PAGO VALUES (8414, 'App', 236.75, 'Rechazado', TO_DATE('2026-01-30', 'YYYY-MM-DD'), 7392);
  INSERT INTO PAGO VALUES (8415, 'QR', 129.10, 'Pendiente', TO_DATE('2026-01-14', 'YYYY-MM-DD'), 7393);
  INSERT INTO PAGO VALUES (8416, 'Tarjeta', 51.51, 'Pendiente', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7394);
  INSERT INTO PAGO VALUES (8417, 'Efectivo', 59.39, 'Pagado', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7395);
  INSERT INTO PAGO VALUES (8418, 'App', 185.96, 'Pagado', TO_DATE('2026-01-29', 'YYYY-MM-DD'), 7396);
  INSERT INTO PAGO VALUES (8419, 'App', 190.66, 'Pagado', TO_DATE('2026-02-07', 'YYYY-MM-DD'), 7397);
  INSERT INTO PAGO VALUES (8420, 'Efectivo', 152.24, 'Pagado', TO_DATE('2026-04-10', 'YYYY-MM-DD'), 7398);
  INSERT INTO PAGO VALUES (8421, 'QR', 212.83, 'Pagado', TO_DATE('2026-01-13', 'YYYY-MM-DD'), 7399);
  INSERT INTO PAGO VALUES (8422, 'Tarjeta', 229.03, 'Rechazado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7400);
  INSERT INTO PAGO VALUES (8423, 'App', 177.81, 'Pagado', TO_DATE('2026-01-19', 'YYYY-MM-DD'), 7401);
  INSERT INTO PAGO VALUES (8424, 'App', 183.57, 'Rechazado', TO_DATE('2026-02-03', 'YYYY-MM-DD'), 7402);
  INSERT INTO PAGO VALUES (8425, 'Tarjeta', 83.71, 'Pagado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7403);
  INSERT INTO PAGO VALUES (8426, 'App', 100.93, 'Pagado', TO_DATE('2026-03-08', 'YYYY-MM-DD'), 7404);
  INSERT INTO PAGO VALUES (8427, 'Transferencia', 246.28, 'Pagado', TO_DATE('2026-02-18', 'YYYY-MM-DD'), 7405);
  INSERT INTO PAGO VALUES (8428, 'Transferencia', 139.32, 'Pendiente', TO_DATE('2026-03-09', 'YYYY-MM-DD'), 7406);
  INSERT INTO PAGO VALUES (8429, 'Transferencia', 110.96, 'Rechazado', TO_DATE('2026-03-12', 'YYYY-MM-DD'), 7407);
  INSERT INTO PAGO VALUES (8430, 'App', 50.43, 'Rechazado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7408);
  INSERT INTO PAGO VALUES (8431, 'Efectivo', 139.54, 'Pagado', TO_DATE('2026-02-25', 'YYYY-MM-DD'), 7409);
  INSERT INTO PAGO VALUES (8432, 'Efectivo', 127.80, 'Pagado', TO_DATE('2026-02-14', 'YYYY-MM-DD'), 7410);
  INSERT INTO PAGO VALUES (8433, 'Efectivo', 212.95, 'Pendiente', TO_DATE('2026-04-19', 'YYYY-MM-DD'), 7411);
  INSERT INTO PAGO VALUES (8434, 'Tarjeta', 173.00, 'Pendiente', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7412);
  INSERT INTO PAGO VALUES (8435, 'Transferencia', 163.21, 'Pagado', TO_DATE('2026-01-20', 'YYYY-MM-DD'), 7413);
  INSERT INTO PAGO VALUES (8436, 'QR', 75.87, 'Pendiente', TO_DATE('2026-03-08', 'YYYY-MM-DD'), 7414);
  INSERT INTO PAGO VALUES (8437, 'Efectivo', 186.72, 'Pagado', TO_DATE('2026-02-21', 'YYYY-MM-DD'), 7415);
  INSERT INTO PAGO VALUES (8438, 'Transferencia', 139.02, 'Pendiente', TO_DATE('2026-04-19', 'YYYY-MM-DD'), 7416);
  INSERT INTO PAGO VALUES (8439, 'Transferencia', 235.89, 'Rechazado', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7417);
  INSERT INTO PAGO VALUES (8440, 'Efectivo', 98.33, 'Pagado', TO_DATE('2026-04-21', 'YYYY-MM-DD'), 7418);
  INSERT INTO PAGO VALUES (8441, 'Tarjeta', 205.19, 'Reembolsado', TO_DATE('2026-04-18', 'YYYY-MM-DD'), 7419);
  INSERT INTO PAGO VALUES (8442, 'App', 65.45, 'Pagado', TO_DATE('2026-04-06', 'YYYY-MM-DD'), 7420);
  INSERT INTO PAGO VALUES (8443, 'Tarjeta', 153.01, 'Rechazado', TO_DATE('2026-01-01', 'YYYY-MM-DD'), 7421);
  INSERT INTO PAGO VALUES (8444, 'Tarjeta', 111.25, 'Pagado', TO_DATE('2026-04-06', 'YYYY-MM-DD'), 7422);
  INSERT INTO PAGO VALUES (8445, 'Efectivo', 97.32, 'Pagado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7423);
  INSERT INTO PAGO VALUES (8446, 'Tarjeta', 70.36, 'Reembolsado', TO_DATE('2026-01-04', 'YYYY-MM-DD'), 7424);
  INSERT INTO PAGO VALUES (8447, 'Tarjeta', 84.64, 'Pagado', TO_DATE('2026-03-10', 'YYYY-MM-DD'), 7425);
  INSERT INTO PAGO VALUES (8448, 'Efectivo', 178.36, 'Pendiente', TO_DATE('2026-02-14', 'YYYY-MM-DD'), 7426);
  INSERT INTO PAGO VALUES (8449, 'Transferencia', 174.01, 'Pagado', TO_DATE('2026-03-21', 'YYYY-MM-DD'), 7427);
  INSERT INTO PAGO VALUES (8450, 'Tarjeta', 66.59, 'Pagado', TO_DATE('2026-04-15', 'YYYY-MM-DD'), 7428);
  INSERT INTO PAGO VALUES (8451, 'Tarjeta', 54.17, 'Pendiente', TO_DATE('2026-03-22', 'YYYY-MM-DD'), 7429);
  INSERT INTO PAGO VALUES (8452, 'Transferencia', 210.61, 'Pagado', TO_DATE('2026-04-14', 'YYYY-MM-DD'), 7430);
  INSERT INTO PAGO VALUES (8453, 'Efectivo', 123.14, 'Pagado', TO_DATE('2026-02-12', 'YYYY-MM-DD'), 7431);
  INSERT INTO PAGO VALUES (8454, 'Tarjeta', 169.80, 'Pagado', TO_DATE('2026-01-26', 'YYYY-MM-DD'), 7432);
  INSERT INTO PAGO VALUES (8455, 'Transferencia', 235.47, 'Pagado', TO_DATE('2026-02-05', 'YYYY-MM-DD'), 7433);
  INSERT INTO PAGO VALUES (8456, 'Transferencia', 96.27, 'Rechazado', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7434);
  INSERT INTO PAGO VALUES (8457, 'Efectivo', 233.08, 'Pendiente', TO_DATE('2026-02-27', 'YYYY-MM-DD'), 7435);
  INSERT INTO PAGO VALUES (8458, 'Transferencia', 161.87, 'Rechazado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7436);
  INSERT INTO PAGO VALUES (8459, 'QR', 179.67, 'Pagado', TO_DATE('2026-01-13', 'YYYY-MM-DD'), 7437);
  INSERT INTO PAGO VALUES (8460, 'QR', 38.09, 'Rechazado', TO_DATE('2026-04-21', 'YYYY-MM-DD'), 7438);
  INSERT INTO PAGO VALUES (8461, 'App', 232.32, 'Pendiente', TO_DATE('2026-02-03', 'YYYY-MM-DD'), 7439);
  INSERT INTO PAGO VALUES (8462, 'App', 200.80, 'Rechazado', TO_DATE('2026-03-09', 'YYYY-MM-DD'), 7440);
  INSERT INTO PAGO VALUES (8463, 'QR', 127.85, 'Pagado', TO_DATE('2026-01-15', 'YYYY-MM-DD'), 7441);
  INSERT INTO PAGO VALUES (8464, 'Transferencia', 192.47, 'Rechazado', TO_DATE('2026-01-27', 'YYYY-MM-DD'), 7442);
  INSERT INTO PAGO VALUES (8465, 'QR', 156.77, 'Rechazado', TO_DATE('2026-04-09', 'YYYY-MM-DD'), 7443);
  INSERT INTO PAGO VALUES (8466, 'App', 161.67, 'Pagado', TO_DATE('2026-04-24', 'YYYY-MM-DD'), 7444);
  INSERT INTO PAGO VALUES (8467, 'Efectivo', 202.96, 'Pagado', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7445);
  INSERT INTO PAGO VALUES (8468, 'Tarjeta', 182.43, 'Rechazado', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7446);
  INSERT INTO PAGO VALUES (8469, 'App', 157.29, 'Pendiente', TO_DATE('2026-04-14', 'YYYY-MM-DD'), 7447);
  INSERT INTO PAGO VALUES (8470, 'Transferencia', 126.79, 'Pagado', TO_DATE('2026-03-04', 'YYYY-MM-DD'), 7448);
  INSERT INTO PAGO VALUES (8471, 'Efectivo', 123.15, 'Pendiente', TO_DATE('2026-02-22', 'YYYY-MM-DD'), 7449);
  INSERT INTO PAGO VALUES (8472, 'App', 176.30, 'Pagado', TO_DATE('2026-02-12', 'YYYY-MM-DD'), 7450);
  INSERT INTO PAGO VALUES (8473, 'Tarjeta', 66.27, 'Pagado', TO_DATE('2026-03-12', 'YYYY-MM-DD'), 7451);
  INSERT INTO PAGO VALUES (8474, 'Transferencia', 62.07, 'Pendiente', TO_DATE('2026-01-29', 'YYYY-MM-DD'), 7452);
  INSERT INTO PAGO VALUES (8475, 'App', 232.90, 'Pagado', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7453);
  INSERT INTO PAGO VALUES (8476, 'Tarjeta', 177.99, 'Rechazado', TO_DATE('2026-03-16', 'YYYY-MM-DD'), 7454);
  INSERT INTO PAGO VALUES (8477, 'Efectivo', 94.14, 'Pagado', TO_DATE('2026-03-01', 'YYYY-MM-DD'), 7455);
  INSERT INTO PAGO VALUES (8478, 'Tarjeta', 138.58, 'Pendiente', TO_DATE('2026-01-16', 'YYYY-MM-DD'), 7456);
  INSERT INTO PAGO VALUES (8479, 'QR', 247.20, 'Pendiente', TO_DATE('2026-03-08', 'YYYY-MM-DD'), 7457);
  INSERT INTO PAGO VALUES (8480, 'Efectivo', 240.70, 'Pagado', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7458);
  INSERT INTO PAGO VALUES (8481, 'Efectivo', 84.18, 'Rechazado', TO_DATE('2026-04-26', 'YYYY-MM-DD'), 7459);
  INSERT INTO PAGO VALUES (8482, 'QR', 196.68, 'Reembolsado', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7460);
  INSERT INTO PAGO VALUES (8483, 'Tarjeta', 45.62, 'Pagado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7461);
  INSERT INTO PAGO VALUES (8484, 'App', 124.87, 'Pagado', TO_DATE('2026-02-23', 'YYYY-MM-DD'), 7462);
  INSERT INTO PAGO VALUES (8485, 'Efectivo', 62.36, 'Reembolsado', TO_DATE('2026-04-18', 'YYYY-MM-DD'), 7463);
  INSERT INTO PAGO VALUES (8486, 'Transferencia', 125.44, 'Pendiente', TO_DATE('2026-04-11', 'YYYY-MM-DD'), 7464);
  INSERT INTO PAGO VALUES (8487, 'Efectivo', 118.86, 'Pagado', TO_DATE('2026-04-21', 'YYYY-MM-DD'), 7465);
  INSERT INTO PAGO VALUES (8488, 'Efectivo', 219.70, 'Pagado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7466);
  INSERT INTO PAGO VALUES (8489, 'App', 259.24, 'Pagado', TO_DATE('2026-01-14', 'YYYY-MM-DD'), 7467);
  INSERT INTO PAGO VALUES (8490, 'Transferencia', 233.94, 'Rechazado', TO_DATE('2026-01-19', 'YYYY-MM-DD'), 7468);
  INSERT INTO PAGO VALUES (8491, 'Efectivo', 260.28, 'Pagado', TO_DATE('2026-01-20', 'YYYY-MM-DD'), 7469);
  INSERT INTO PAGO VALUES (8492, 'Transferencia', 216.51, 'Pagado', TO_DATE('2026-01-27', 'YYYY-MM-DD'), 7470);
  INSERT INTO PAGO VALUES (8493, 'Transferencia', 242.59, 'Pagado', TO_DATE('2026-04-24', 'YYYY-MM-DD'), 7471);
  INSERT INTO PAGO VALUES (8494, 'App', 222.93, 'Pendiente', TO_DATE('2026-04-09', 'YYYY-MM-DD'), 7472);
  INSERT INTO PAGO VALUES (8495, 'App', 232.82, 'Rechazado', TO_DATE('2026-01-21', 'YYYY-MM-DD'), 7473);
  INSERT INTO PAGO VALUES (8496, 'Tarjeta', 88.62, 'Pagado', TO_DATE('2026-01-11', 'YYYY-MM-DD'), 7474);
  INSERT INTO PAGO VALUES (8497, 'Efectivo', 54.17, 'Pagado', TO_DATE('2026-04-03', 'YYYY-MM-DD'), 7475);
  INSERT INTO PAGO VALUES (8498, 'Transferencia', 212.03, 'Pagado', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7476);
  INSERT INTO PAGO VALUES (8499, 'QR', 70.03, 'Rechazado', TO_DATE('2026-04-05', 'YYYY-MM-DD'), 7477);
  INSERT INTO PAGO VALUES (8500, 'Transferencia', 129.07, 'Pendiente', TO_DATE('2026-01-29', 'YYYY-MM-DD'), 7478);
  COMMIT;
END;

--bloque 6
BEGIN
  INSERT INTO PAGO VALUES (8501, 'Tarjeta', 220.68, 'Pagado', TO_DATE('2026-01-09', 'YYYY-MM-DD'), 7479);
  INSERT INTO PAGO VALUES (8502, 'Efectivo', 56.02, 'Pagado', TO_DATE('2026-04-20', 'YYYY-MM-DD'), 7480);
  INSERT INTO PAGO VALUES (8503, 'Tarjeta', 154.73, 'Pagado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7481);
  INSERT INTO PAGO VALUES (8504, 'QR', 190.43, 'Rechazado', TO_DATE('2026-03-24', 'YYYY-MM-DD'), 7482);
  INSERT INTO PAGO VALUES (8505, 'Efectivo', 135.02, 'Pagado', TO_DATE('2026-04-08', 'YYYY-MM-DD'), 7483);
  INSERT INTO PAGO VALUES (8506, 'App', 155.89, 'Rechazado', TO_DATE('2026-03-26', 'YYYY-MM-DD'), 7484);
  INSERT INTO PAGO VALUES (8507, 'QR', 135.57, 'Pagado', TO_DATE('2026-01-31', 'YYYY-MM-DD'), 7485);
  INSERT INTO PAGO VALUES (8508, 'Tarjeta', 206.54, 'Rechazado', TO_DATE('2026-01-19', 'YYYY-MM-DD'), 7486);
  INSERT INTO PAGO VALUES (8509, 'App', 158.03, 'Pagado', TO_DATE('2026-04-06', 'YYYY-MM-DD'), 7487);
  INSERT INTO PAGO VALUES (8510, 'Efectivo', 220.33, 'Pendiente', TO_DATE('2026-01-03', 'YYYY-MM-DD'), 7488);
  INSERT INTO PAGO VALUES (8511, 'Efectivo', 147.91, 'Pendiente', TO_DATE('2026-01-30', 'YYYY-MM-DD'), 7489);
  INSERT INTO PAGO VALUES (8512, 'Transferencia', 195.07, 'Pendiente', TO_DATE('2026-01-18', 'YYYY-MM-DD'), 7490);
  INSERT INTO PAGO VALUES (8513, 'Transferencia', 51.41, 'Rechazado', TO_DATE('2026-01-08', 'YYYY-MM-DD'), 7491);
  INSERT INTO PAGO VALUES (8514, 'Tarjeta', 215.86, 'Pendiente', TO_DATE('2026-02-09', 'YYYY-MM-DD'), 7492);
  INSERT INTO PAGO VALUES (8515, 'QR', 61.99, 'Reembolsado', TO_DATE('2026-03-01', 'YYYY-MM-DD'), 7493);
  INSERT INTO PAGO VALUES (8516, 'App', 143.38, 'Pendiente', TO_DATE('2026-04-22', 'YYYY-MM-DD'), 7494);
  INSERT INTO PAGO VALUES (8517, 'Efectivo', 102.27, 'Rechazado', TO_DATE('2026-03-31', 'YYYY-MM-DD'), 7495);
  INSERT INTO PAGO VALUES (8518, 'Efectivo', 75.38, 'Pagado', TO_DATE('2026-04-05', 'YYYY-MM-DD'), 7496);
  INSERT INTO PAGO VALUES (8519, 'Tarjeta', 137.74, 'Rechazado', TO_DATE('2026-01-30', 'YYYY-MM-DD'), 7497);
  INSERT INTO PAGO VALUES (8520, 'QR', 192.13, 'Pendiente', TO_DATE('2026-01-25', 'YYYY-MM-DD'), 7498);
  INSERT INTO PAGO VALUES (8521, 'QR', 86.38, 'Rechazado', TO_DATE('2026-01-31', 'YYYY-MM-DD'), 7499);
  INSERT INTO PAGO VALUES (8522, 'App', 212.18, 'Pendiente', TO_DATE('2026-02-17', 'YYYY-MM-DD'), 7500);
  COMMIT;
END;


--FACTURA 
--bloque 1
BEGIN
  INSERT INTO FACTURA VALUES (9001, 'F-2026-09001', TO_DATE('2026-02-18', 'YYYY-MM-DD'), TO_DATE('2026-03-20', 'YYYY-MM-DD'), 182.25, 197.25, 'Emitida', 7001);
  INSERT INTO FACTURA VALUES (9002, 'F-2026-09002', TO_DATE('2026-01-27', 'YYYY-MM-DD'), TO_DATE('2026-02-11', 'YYYY-MM-DD'), 209.61, 219.61, 'Anulada', 7002);
  INSERT INTO FACTURA VALUES (9003, 'F-2026-09003', TO_DATE('2026-03-22', 'YYYY-MM-DD'), TO_DATE('2026-05-06', 'YYYY-MM-DD'), 213.91, 223.91, 'Emitida', 7003);
  INSERT INTO FACTURA VALUES (9004, 'F-2026-09004', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-04-18', 'YYYY-MM-DD'), 43.18, 53.18, 'Anulada', 7004);
  INSERT INTO FACTURA VALUES (9005, 'F-2026-09005', TO_DATE('2026-04-06', 'YYYY-MM-DD'), TO_DATE('2026-04-21', 'YYYY-MM-DD'), 115.42, 125.42, 'Pagada', 7005);
  INSERT INTO FACTURA VALUES (9006, 'F-2026-09006', TO_DATE('2026-02-23', 'YYYY-MM-DD'), TO_DATE('2026-03-10', 'YYYY-MM-DD'), 219.61, 229.61, 'Pagada', 7006);
  INSERT INTO FACTURA VALUES (9007, 'F-2026-09007', TO_DATE('2026-03-01', 'YYYY-MM-DD'), TO_DATE('2026-03-31', 'YYYY-MM-DD'), 56.66, 76.66, 'Emitida', 7007);
  INSERT INTO FACTURA VALUES (9008, 'F-2026-09008', TO_DATE('2026-04-26', 'YYYY-MM-DD'), TO_DATE('2026-05-26', 'YYYY-MM-DD'), 95.83, 105.83, 'Anulada', 7008);
  INSERT INTO FACTURA VALUES (9009, 'F-2026-09009', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-05-08', 'YYYY-MM-DD'), 224.22, 244.22, 'Pagada', 7009);
  INSERT INTO FACTURA VALUES (9010, 'F-2026-09010', TO_DATE('2026-01-28', 'YYYY-MM-DD'), TO_DATE('2026-02-12', 'YYYY-MM-DD'), 115.54, 130.54, 'Emitida', 7010);
  INSERT INTO FACTURA VALUES (9011, 'F-2026-09011', TO_DATE('2026-02-19', 'YYYY-MM-DD'), TO_DATE('2026-04-05', 'YYYY-MM-DD'), 125.79, 135.79, 'Emitida', 7011);
  INSERT INTO FACTURA VALUES (9012, 'F-2026-09012', TO_DATE('2026-03-12', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 112.55, 127.55, 'Pagada', 7012);
  INSERT INTO FACTURA VALUES (9013, 'F-2026-09013', TO_DATE('2026-02-28', 'YYYY-MM-DD'), TO_DATE('2026-04-14', 'YYYY-MM-DD'), 196.22, 216.22, 'Pagada', 7013);
  INSERT INTO FACTURA VALUES (9014, 'F-2026-09014', TO_DATE('2026-04-09', 'YYYY-MM-DD'), TO_DATE('2026-04-24', 'YYYY-MM-DD'), 171.05, 191.05, 'Pagada', 7014);
  INSERT INTO FACTURA VALUES (9015, 'F-2026-09015', TO_DATE('2026-02-17', 'YYYY-MM-DD'), TO_DATE('2026-03-04', 'YYYY-MM-DD'), 61.27, 81.27, 'Emitida', 7015);
  INSERT INTO FACTURA VALUES (9016, 'F-2026-09016', TO_DATE('2026-02-16', 'YYYY-MM-DD'), TO_DATE('2026-03-18', 'YYYY-MM-DD'), 199.11, 209.11, 'Emitida', 7016);
  INSERT INTO FACTURA VALUES (9017, 'F-2026-09017', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-04-08', 'YYYY-MM-DD'), 115.65, 125.65, 'Emitida', 7017);
  INSERT INTO FACTURA VALUES (9018, 'F-2026-09018', TO_DATE('2026-04-17', 'YYYY-MM-DD'), TO_DATE('2026-05-02', 'YYYY-MM-DD'), 145.42, 160.42, 'Pagada', 7018);
  INSERT INTO FACTURA VALUES (9019, 'F-2026-09019', TO_DATE('2026-04-04', 'YYYY-MM-DD'), TO_DATE('2026-05-19', 'YYYY-MM-DD'), 166.30, 186.30, 'Pagada', 7019);
  INSERT INTO FACTURA VALUES (9020, 'F-2026-09020', TO_DATE('2026-02-14', 'YYYY-MM-DD'), TO_DATE('2026-03-01', 'YYYY-MM-DD'), 202.94, 217.94, 'Pagada', 7020);
  INSERT INTO FACTURA VALUES (9021, 'F-2026-09021', TO_DATE('2026-02-09', 'YYYY-MM-DD'), TO_DATE('2026-02-24', 'YYYY-MM-DD'), 191.07, 211.07, 'Pagada', 7021);
  INSERT INTO FACTURA VALUES (9022, 'F-2026-09022', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-05-20', 'YYYY-MM-DD'), 125.10, 140.10, 'Pagada', 7022);
  INSERT INTO FACTURA VALUES (9023, 'F-2026-09023', TO_DATE('2026-01-20', 'YYYY-MM-DD'), TO_DATE('2026-02-19', 'YYYY-MM-DD'), 180.12, 195.12, 'Pagada', 7023);
  INSERT INTO FACTURA VALUES (9024, 'F-2026-09024', TO_DATE('2026-04-13', 'YYYY-MM-DD'), TO_DATE('2026-04-28', 'YYYY-MM-DD'), 102.77, 117.77, 'Anulada', 7024);
  INSERT INTO FACTURA VALUES (9025, 'F-2026-09025', TO_DATE('2026-01-19', 'YYYY-MM-DD'), TO_DATE('2026-02-18', 'YYYY-MM-DD'), 86.82, 101.82, 'Pagada', 7025);
  INSERT INTO FACTURA VALUES (9026, 'F-2026-09026', TO_DATE('2026-03-12', 'YYYY-MM-DD'), TO_DATE('2026-04-11', 'YYYY-MM-DD'), 195.27, 215.27, 'Pagada', 7026);
  INSERT INTO FACTURA VALUES (9027, 'F-2026-09027', TO_DATE('2026-02-08', 'YYYY-MM-DD'), TO_DATE('2026-03-10', 'YYYY-MM-DD'), 198.80, 208.80, 'Pagada', 7027);
  INSERT INTO FACTURA VALUES (9028, 'F-2026-09028', TO_DATE('2026-02-23', 'YYYY-MM-DD'), TO_DATE('2026-03-10', 'YYYY-MM-DD'), 69.41, 79.41, 'Pagada', 7028);
  INSERT INTO FACTURA VALUES (9029, 'F-2026-09029', TO_DATE('2026-02-24', 'YYYY-MM-DD'), TO_DATE('2026-04-10', 'YYYY-MM-DD'), 175.77, 185.77, 'Pagada', 7029);
  INSERT INTO FACTURA VALUES (9030, 'F-2026-09030', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-05-18', 'YYYY-MM-DD'), 145.24, 155.24, 'Pagada', 7030);
  INSERT INTO FACTURA VALUES (9031, 'F-2026-09031', TO_DATE('2026-04-17', 'YYYY-MM-DD'), TO_DATE('2026-05-02', 'YYYY-MM-DD'), 87.89, 97.89, 'Emitida', 7031);
  INSERT INTO FACTURA VALUES (9032, 'F-2026-09032', TO_DATE('2026-01-21', 'YYYY-MM-DD'), TO_DATE('2026-03-07', 'YYYY-MM-DD'), 92.20, 112.20, 'Pagada', 7032);
  INSERT INTO FACTURA VALUES (9033, 'F-2026-09033', TO_DATE('2026-03-03', 'YYYY-MM-DD'), TO_DATE('2026-03-18', 'YYYY-MM-DD'), 42.13, 57.13, 'Emitida', 7033);
  INSERT INTO FACTURA VALUES (9034, 'F-2026-09034', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-04-18', 'YYYY-MM-DD'), 81.33, 101.33, 'Anulada', 7034);
  INSERT INTO FACTURA VALUES (9035, 'F-2026-09035', TO_DATE('2026-01-30', 'YYYY-MM-DD'), TO_DATE('2026-03-16', 'YYYY-MM-DD'), 176.43, 196.43, 'Emitida', 7035);
  INSERT INTO FACTURA VALUES (9036, 'F-2026-09036', TO_DATE('2026-04-07', 'YYYY-MM-DD'), TO_DATE('2026-05-07', 'YYYY-MM-DD'), 160.77, 180.77, 'Anulada', 7036);
  INSERT INTO FACTURA VALUES (9037, 'F-2026-09037', TO_DATE('2026-02-15', 'YYYY-MM-DD'), TO_DATE('2026-04-01', 'YYYY-MM-DD'), 81.70, 96.70, 'Emitida', 7037);
  INSERT INTO FACTURA VALUES (9038, 'F-2026-09038', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-04-23', 'YYYY-MM-DD'), 56.63, 66.63, 'Emitida', 7038);
  INSERT INTO FACTURA VALUES (9039, 'F-2026-09039', TO_DATE('2026-04-12', 'YYYY-MM-DD'), TO_DATE('2026-04-27', 'YYYY-MM-DD'), 196.15, 206.15, 'Pagada', 7039);
  INSERT INTO FACTURA VALUES (9040, 'F-2026-09040', TO_DATE('2026-04-22', 'YYYY-MM-DD'), TO_DATE('2026-05-07', 'YYYY-MM-DD'), 100.99, 115.99, 'Pagada', 7040);
  INSERT INTO FACTURA VALUES (9041, 'F-2026-09041', TO_DATE('2026-02-13', 'YYYY-MM-DD'), TO_DATE('2026-02-28', 'YYYY-MM-DD'), 42.14, 57.14, 'Pagada', 7041);
  INSERT INTO FACTURA VALUES (9042, 'F-2026-09042', TO_DATE('2026-04-18', 'YYYY-MM-DD'), TO_DATE('2026-05-03', 'YYYY-MM-DD'), 53.96, 68.96, 'Pagada', 7042);
  INSERT INTO FACTURA VALUES (9043, 'F-2026-09043', TO_DATE('2026-02-23', 'YYYY-MM-DD'), TO_DATE('2026-03-10', 'YYYY-MM-DD'), 202.99, 212.99, 'Pagada', 7043);
  INSERT INTO FACTURA VALUES (9044, 'F-2026-09044', TO_DATE('2026-02-13', 'YYYY-MM-DD'), TO_DATE('2026-03-30', 'YYYY-MM-DD'), 224.23, 234.23, 'Pagada', 7044);
  INSERT INTO FACTURA VALUES (9045, 'F-2026-09045', TO_DATE('2026-03-02', 'YYYY-MM-DD'), TO_DATE('2026-04-01', 'YYYY-MM-DD'), 56.40, 66.40, 'Emitida', 7045);
  INSERT INTO FACTURA VALUES (9046, 'F-2026-09046', TO_DATE('2026-03-05', 'YYYY-MM-DD'), TO_DATE('2026-04-19', 'YYYY-MM-DD'), 167.31, 187.31, 'Pagada', 7046);
  INSERT INTO FACTURA VALUES (9047, 'F-2026-09047', TO_DATE('2026-02-25', 'YYYY-MM-DD'), TO_DATE('2026-03-27', 'YYYY-MM-DD'), 217.16, 232.16, 'Emitida', 7047);
  INSERT INTO FACTURA VALUES (9048, 'F-2026-09048', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-04-18', 'YYYY-MM-DD'), 137.52, 147.52, 'Emitida', 7048);
  INSERT INTO FACTURA VALUES (9049, 'F-2026-09049', TO_DATE('2026-04-18', 'YYYY-MM-DD'), TO_DATE('2026-05-18', 'YYYY-MM-DD'), 43.18, 53.18, 'Pagada', 7049);
  INSERT INTO FACTURA VALUES (9050, 'F-2026-09050', TO_DATE('2026-01-29', 'YYYY-MM-DD'), TO_DATE('2026-02-28', 'YYYY-MM-DD'), 218.41, 238.41, 'Anulada', 7050);
  INSERT INTO FACTURA VALUES (9051, 'F-2026-09051', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-05-05', 'YYYY-MM-DD'), 94.61, 104.61, 'Anulada', 7051);
  INSERT INTO FACTURA VALUES (9052, 'F-2026-09052', TO_DATE('2026-03-31', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 164.73, 174.73, 'Pagada', 7052);
  INSERT INTO FACTURA VALUES (9053, 'F-2026-09053', TO_DATE('2026-04-14', 'YYYY-MM-DD'), TO_DATE('2026-05-29', 'YYYY-MM-DD'), 125.79, 135.79, 'Pagada', 7053);
  INSERT INTO FACTURA VALUES (9054, 'F-2026-09054', TO_DATE('2026-03-31', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 196.22, 206.22, 'Pagada', 7054);
  INSERT INTO FACTURA VALUES (9055, 'F-2026-09055', TO_DATE('2026-04-23', 'YYYY-MM-DD'), TO_DATE('2026-05-08', 'YYYY-MM-DD'), 56.63, 66.63, 'Emitida', 7055);
  INSERT INTO FACTURA VALUES (9056, 'F-2026-09056', TO_DATE('2026-04-23', 'YYYY-MM-DD'), TO_DATE('2026-05-23', 'YYYY-MM-DD'), 153.05, 173.05, 'Pagada', 7056);
  INSERT INTO FACTURA VALUES (9057, 'F-2026-09057', TO_DATE('2026-04-12', 'YYYY-MM-DD'), TO_DATE('2026-05-12', 'YYYY-MM-DD'), 217.16, 237.16, 'Emitida', 7057);
  INSERT INTO FACTURA VALUES (9058, 'F-2026-09058', TO_DATE('2026-01-08', 'YYYY-MM-DD'), TO_DATE('2026-02-22', 'YYYY-MM-DD'), 125.79, 135.79, 'Pagada', 7058);
  INSERT INTO FACTURA VALUES (9059, 'F-2026-09059', TO_DATE('2026-04-18', 'YYYY-MM-DD'), TO_DATE('2026-05-18', 'YYYY-MM-DD'), 219.00, 239.00, 'Emitida', 7059);
  INSERT INTO FACTURA VALUES (9060, 'F-2026-09060', TO_DATE('2026-02-25', 'YYYY-MM-DD'), TO_DATE('2026-03-27', 'YYYY-MM-DD'), 167.31, 187.31, 'Anulada', 7060);
  INSERT INTO FACTURA VALUES (9061, 'F-2026-09061', TO_DATE('2026-03-31', 'YYYY-MM-DD'), TO_DATE('2026-04-15', 'YYYY-MM-DD'), 61.27, 76.27, 'Emitida', 7061);
  INSERT INTO FACTURA VALUES (9062, 'F-2026-09062', TO_DATE('2026-02-25', 'YYYY-MM-DD'), TO_DATE('2026-04-11', 'YYYY-MM-DD'), 102.77, 117.77, 'Emitida', 7062);
  INSERT INTO FACTURA VALUES (9063, 'F-2026-09063', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-05-20', 'YYYY-MM-DD'), 196.22, 211.22, 'Pagada', 7063);
  INSERT INTO FACTURA VALUES (9064, 'F-2026-09064', TO_DATE('2026-03-12', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 42.14, 57.14, 'Anulada', 7064);
  INSERT INTO FACTURA VALUES (9065, 'F-2026-09065', TO_DATE('2026-03-22', 'YYYY-MM-DD'), TO_DATE('2026-04-06', 'YYYY-MM-DD'), 125.79, 140.79, 'Pagada', 7065);
  INSERT INTO FACTURA VALUES (9066, 'F-2026-09066', TO_DATE('2026-02-14', 'YYYY-MM-DD'), TO_DATE('2026-03-01', 'YYYY-MM-DD'), 115.54, 130.54, 'Emitida', 7066);
  INSERT INTO FACTURA VALUES (9067, 'F-2026-09067', TO_DATE('2026-03-01', 'YYYY-MM-DD'), TO_DATE('2026-03-31', 'YYYY-MM-DD'), 219.61, 229.61, 'Pagada', 7067);
  INSERT INTO FACTURA VALUES (9068, 'F-2026-09068', TO_DATE('2026-01-27', 'YYYY-MM-DD'), TO_DATE('2026-02-11', 'YYYY-MM-DD'), 167.31, 187.31, 'Emitida', 7068);
  INSERT INTO FACTURA VALUES (9069, 'F-2026-09069', TO_DATE('2026-04-18', 'YYYY-MM-DD'), TO_DATE('2026-05-18', 'YYYY-MM-DD'), 219.00, 239.00, 'Anulada', 7069);
  INSERT INTO FACTURA VALUES (9070, 'F-2026-09070', TO_DATE('2026-01-08', 'YYYY-MM-DD'), TO_DATE('2026-02-07', 'YYYY-MM-DD'), 160.77, 175.77, 'Pagada', 7070);
  INSERT INTO FACTURA VALUES (9071, 'F-2026-09071', TO_DATE('2026-04-12', 'YYYY-MM-DD'), TO_DATE('2026-05-12', 'YYYY-MM-DD'), 137.52, 147.52, 'Emitida', 7071);
  INSERT INTO FACTURA VALUES (9072, 'F-2026-09072', TO_DATE('2026-02-25', 'YYYY-MM-DD'), TO_DATE('2026-03-12', 'YYYY-MM-DD'), 171.05, 186.05, 'Pagada', 7072);
  INSERT INTO FACTURA VALUES (9073, 'F-2026-09073', TO_DATE('2026-03-05', 'YYYY-MM-DD'), TO_DATE('2026-04-04', 'YYYY-MM-DD'), 112.55, 132.55, 'Pagada', 7073);
  INSERT INTO FACTURA VALUES (9074, 'F-2026-09074', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-05-08', 'YYYY-MM-DD'), 125.79, 135.79, 'Anulada', 7074);
  INSERT INTO FACTURA VALUES (9075, 'F-2026-09075', TO_DATE('2026-04-26', 'YYYY-MM-DD'), TO_DATE('2026-05-26', 'YYYY-MM-DD'), 115.54, 135.54, 'Emitida', 7075);
  INSERT INTO FACTURA VALUES (9076, 'F-2026-09076', TO_DATE('2026-02-23', 'YYYY-MM-DD'), TO_DATE('2026-04-09', 'YYYY-MM-DD'), 224.22, 239.22, 'Emitida', 7076);
  INSERT INTO FACTURA VALUES (9077, 'F-2026-09077', TO_DATE('2026-04-06', 'YYYY-MM-DD'), TO_DATE('2026-05-21', 'YYYY-MM-DD'), 95.83, 105.83, 'Pagada', 7077);
  INSERT INTO FACTURA VALUES (9078, 'F-2026-09078', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-04-18', 'YYYY-MM-DD'), 56.66, 76.66, 'Emitida', 7078);
  INSERT INTO FACTURA VALUES (9079, 'F-2026-09079', TO_DATE('2026-03-22', 'YYYY-MM-DD'), TO_DATE('2026-04-21', 'YYYY-MM-DD'), 219.61, 239.61, 'Pagada', 7079);
  INSERT INTO FACTURA VALUES (9080, 'F-2026-09080', TO_DATE('2026-01-27', 'YYYY-MM-DD'), TO_DATE('2026-02-26', 'YYYY-MM-DD'), 115.42, 125.42, 'Anulada', 7080);
  INSERT INTO FACTURA VALUES (9081, 'F-2026-09081', TO_DATE('2026-02-18', 'YYYY-MM-DD'), TO_DATE('2026-03-05', 'YYYY-MM-DD'), 43.18, 58.18, 'Emitida', 7081);
  INSERT INTO FACTURA VALUES (9082, 'F-2026-09082', TO_DATE('2026-04-18', 'YYYY-MM-DD'), TO_DATE('2026-05-18', 'YYYY-MM-DD'), 213.91, 233.91, 'Pagada', 7082);
  INSERT INTO FACTURA VALUES (9083, 'F-2026-09083', TO_DATE('2026-02-13', 'YYYY-MM-DD'), TO_DATE('2026-03-15', 'YYYY-MM-DD'), 209.61, 219.61, 'Pagada', 7083);
  INSERT INTO FACTURA VALUES (9084, 'F-2026-09084', TO_DATE('2026-04-22', 'YYYY-MM-DD'), TO_DATE('2026-05-22', 'YYYY-MM-DD'), 182.25, 197.25, 'Emitida', 7084);
  INSERT INTO FACTURA VALUES (9085, 'F-2026-09085', TO_DATE('2026-04-12', 'YYYY-MM-DD'), TO_DATE('2026-04-27', 'YYYY-MM-DD'), 180.12, 190.12, 'Pagada', 7085);
  INSERT INTO FACTURA VALUES (9086, 'F-2026-09086', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-04-08', 'YYYY-MM-DD'), 125.10, 140.10, 'Pagada', 7086);
  INSERT INTO FACTURA VALUES (9087, 'F-2026-09087', TO_DATE('2026-02-15', 'YYYY-MM-DD'), TO_DATE('2026-03-02', 'YYYY-MM-DD'), 191.07, 211.07, 'Emitida', 7087);
  INSERT INTO FACTURA VALUES (9088, 'F-2026-09088', TO_DATE('2026-04-07', 'YYYY-MM-DD'), TO_DATE('2026-04-22', 'YYYY-MM-DD'), 202.94, 212.94, 'Emitida', 7088);
  INSERT INTO FACTURA VALUES (9089, 'F-2026-09089', TO_DATE('2026-01-30', 'YYYY-MM-DD'), TO_DATE('2026-03-16', 'YYYY-MM-DD'), 166.30, 181.30, 'Anulada', 7089);
  INSERT INTO FACTURA VALUES (9090, 'F-2026-09090', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-04-18', 'YYYY-MM-DD'), 145.42, 160.42, 'Pagada', 7090);
  INSERT INTO FACTURA VALUES (9091, 'F-2026-09091', TO_DATE('2026-03-03', 'YYYY-MM-DD'), TO_DATE('2026-04-17', 'YYYY-MM-DD'), 115.65, 125.65, 'Emitida', 7091);
  INSERT INTO FACTURA VALUES (9092, 'F-2026-09092', TO_DATE('2026-01-21', 'YYYY-MM-DD'), TO_DATE('2026-02-20', 'YYYY-MM-DD'), 199.11, 209.11, 'Anulada', 7092);
  INSERT INTO FACTURA VALUES (9093, 'F-2026-09093', TO_DATE('2026-04-17', 'YYYY-MM-DD'), TO_DATE('2026-05-17', 'YYYY-MM-DD'), 61.27, 81.27, 'Pagada', 7093);
  INSERT INTO FACTURA VALUES (9094, 'F-2026-09094', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-05-03', 'YYYY-MM-DD'), 171.05, 191.05, 'Pagada', 7094);
  INSERT INTO FACTURA VALUES (9095, 'F-2026-09095', TO_DATE('2026-02-24', 'YYYY-MM-DD'), TO_DATE('2026-03-26', 'YYYY-MM-DD'), 196.22, 216.22, 'Pagada', 7095);
  INSERT INTO FACTURA VALUES (9096, 'F-2026-09096', TO_DATE('2026-02-23', 'YYYY-MM-DD'), TO_DATE('2026-03-10', 'YYYY-MM-DD'), 112.55, 127.55, 'Pagada', 7096);
  INSERT INTO FACTURA VALUES (9097, 'F-2026-09097', TO_DATE('2026-02-08', 'YYYY-MM-DD'), TO_DATE('2026-02-23', 'YYYY-MM-DD'), 125.79, 140.79, 'Pagada', 7097);
  INSERT INTO FACTURA VALUES (9098, 'F-2026-09098', TO_DATE('2026-03-12', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 115.54, 135.54, 'Emitida', 7098);
  INSERT INTO FACTURA VALUES (9099, 'F-2026-09099', TO_DATE('2026-01-19', 'YYYY-MM-DD'), TO_DATE('2026-03-05', 'YYYY-MM-DD'), 224.22, 239.22, 'Emitida', 7099);
  INSERT INTO FACTURA VALUES (9100, 'F-2026-09100', TO_DATE('2026-04-13', 'YYYY-MM-DD'), TO_DATE('2026-05-28', 'YYYY-MM-DD'), 95.83, 105.83, 'Emitida', 7100);
  COMMIT;
END;

--bloque 2
BEGIN
  INSERT INTO FACTURA VALUES (9101, 'F-2026-09101', TO_DATE('2026-01-20', 'YYYY-MM-DD'), TO_DATE('2026-03-06', 'YYYY-MM-DD'), 56.66, 71.66, 'Emitida', 7101);
  INSERT INTO FACTURA VALUES (9102, 'F-2026-09102', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-05-20', 'YYYY-MM-DD'), 219.61, 239.61, 'Pagada', 7102);
  INSERT INTO FACTURA VALUES (9103, 'F-2026-09103', TO_DATE('2026-02-09', 'YYYY-MM-DD'), TO_DATE('2026-03-26', 'YYYY-MM-DD'), 115.54, 130.54, 'Pagada', 7103);
  INSERT INTO FACTURA VALUES (9104, 'F-2026-09104', TO_DATE('2026-02-14', 'YYYY-MM-DD'), TO_DATE('2026-03-16', 'YYYY-MM-DD'), 125.79, 140.79, 'Emitida', 7104);
  INSERT INTO FACTURA VALUES (9105, 'F-2026-09105', TO_DATE('2026-04-04', 'YYYY-MM-DD'), TO_DATE('2026-05-04', 'YYYY-MM-DD'), 42.14, 52.14, 'Pagada', 7105);
  INSERT INTO FACTURA VALUES (9106, 'F-2026-09106', TO_DATE('2026-04-17', 'YYYY-MM-DD'), TO_DATE('2026-05-17', 'YYYY-MM-DD'), 196.22, 211.22, 'Pagada', 7106);
  INSERT INTO FACTURA VALUES (9107, 'F-2026-09107', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-04-08', 'YYYY-MM-DD'), 102.77, 112.77, 'Anulada', 7107);
  INSERT INTO FACTURA VALUES (9108, 'F-2026-09108', TO_DATE('2026-02-16', 'YYYY-MM-DD'), TO_DATE('2026-03-03', 'YYYY-MM-DD'), 61.27, 76.27, 'Anulada', 7108);
  INSERT INTO FACTURA VALUES (9109, 'F-2026-09109', TO_DATE('2026-02-17', 'YYYY-MM-DD'), TO_DATE('2026-03-04', 'YYYY-MM-DD'), 167.31, 187.31, 'Anulada', 7109);
  INSERT INTO FACTURA VALUES (9110, 'F-2026-09110', TO_DATE('2026-04-09', 'YYYY-MM-DD'), TO_DATE('2026-05-09', 'YYYY-MM-DD'), 219.00, 239.00, 'Emitida', 7110);
  INSERT INTO FACTURA VALUES (9111, 'F-2026-09111', TO_DATE('2026-02-28', 'YYYY-MM-DD'), TO_DATE('2026-03-15', 'YYYY-MM-DD'), 125.79, 135.79, 'Anulada', 7111);
  INSERT INTO FACTURA VALUES (9112, 'F-2026-09112', TO_DATE('2026-03-12', 'YYYY-MM-DD'), TO_DATE('2026-04-11', 'YYYY-MM-DD'), 217.16, 227.16, 'Pagada', 7112);
  INSERT INTO FACTURA VALUES (9113, 'F-2026-09113', TO_DATE('2026-02-19', 'YYYY-MM-DD'), TO_DATE('2026-03-06', 'YYYY-MM-DD'), 153.05, 173.05, 'Anulada', 7113);
  INSERT INTO FACTURA VALUES (9114, 'F-2026-09114', TO_DATE('2026-01-28', 'YYYY-MM-DD'), TO_DATE('2026-03-14', 'YYYY-MM-DD'), 56.63, 66.63, 'Anulada', 7114);
  INSERT INTO FACTURA VALUES (9115, 'F-2026-09115', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-05-08', 'YYYY-MM-DD'), 196.22, 216.22, 'Emitida', 7115);
  INSERT INTO FACTURA VALUES (9116, 'F-2026-09116', TO_DATE('2026-04-26', 'YYYY-MM-DD'), TO_DATE('2026-05-11', 'YYYY-MM-DD'), 125.79, 140.79, 'Pagada', 7116);
  INSERT INTO FACTURA VALUES (9117, 'F-2026-09117', TO_DATE('2026-03-01', 'YYYY-MM-DD'), TO_DATE('2026-03-16', 'YYYY-MM-DD'), 164.73, 174.73, 'Pagada', 7117);
  INSERT INTO FACTURA VALUES (9118, 'F-2026-09118', TO_DATE('2026-02-23', 'YYYY-MM-DD'), TO_DATE('2026-04-09', 'YYYY-MM-DD'), 94.61, 114.61, 'Pagada', 7118);
  INSERT INTO FACTURA VALUES (9119, 'F-2026-09119', TO_DATE('2026-04-06', 'YYYY-MM-DD'), TO_DATE('2026-04-21', 'YYYY-MM-DD'), 218.41, 238.41, 'Pagada', 7119);
  INSERT INTO FACTURA VALUES (9120, 'F-2026-09120', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-05-18', 'YYYY-MM-DD'), 43.18, 58.18, 'Anulada', 7120);
  INSERT INTO FACTURA VALUES (9121, 'F-2026-09121', TO_DATE('2026-03-22', 'YYYY-MM-DD'), TO_DATE('2026-04-06', 'YYYY-MM-DD'), 137.52, 147.52, 'Emitida', 7121);
  INSERT INTO FACTURA VALUES (9122, 'F-2026-09122', TO_DATE('2026-01-27', 'YYYY-MM-DD'), TO_DATE('2026-03-13', 'YYYY-MM-DD'), 217.16, 237.16, 'Pagada', 7122);
  INSERT INTO FACTURA VALUES (9123, 'F-2026-09123', TO_DATE('2026-02-18', 'YYYY-MM-DD'), TO_DATE('2026-03-20', 'YYYY-MM-DD'), 167.31, 177.31, 'Emitida', 7123);
  INSERT INTO FACTURA VALUES (9124, 'F-2026-09124', TO_DATE('2026-04-18', 'YYYY-MM-DD'), TO_DATE('2026-05-03', 'YYYY-MM-DD'), 56.40, 71.40, 'Pagada', 7124);
  INSERT INTO FACTURA VALUES (9125, 'F-2026-09125', TO_DATE('2026-02-13', 'YYYY-MM-DD'), TO_DATE('2026-02-28', 'YYYY-MM-DD'), 224.23, 239.23, 'Anulada', 7125);
  INSERT INTO FACTURA VALUES (9126, 'F-2026-09126', TO_DATE('2026-04-22', 'YYYY-MM-DD'), TO_DATE('2026-05-22', 'YYYY-MM-DD'), 202.99, 217.99, 'Pagada', 7126);
  INSERT INTO FACTURA VALUES (9127, 'F-2026-09127', TO_DATE('2026-04-12', 'YYYY-MM-DD'), TO_DATE('2026-05-27', 'YYYY-MM-DD'), 53.96, 68.96, 'Pagada', 7127);
  INSERT INTO FACTURA VALUES (9128, 'F-2026-09128', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-05-08', 'YYYY-MM-DD'), 42.14, 52.14, 'Anulada', 7128);
  INSERT INTO FACTURA VALUES (9129, 'F-2026-09129', TO_DATE('2026-02-15', 'YYYY-MM-DD'), TO_DATE('2026-03-17', 'YYYY-MM-DD'), 100.99, 115.99, 'Pagada', 7129);
  INSERT INTO FACTURA VALUES (9130, 'F-2026-09130', TO_DATE('2026-04-07', 'YYYY-MM-DD'), TO_DATE('2026-04-22', 'YYYY-MM-DD'), 196.15, 216.15, 'Pagada', 7130);
  INSERT INTO FACTURA VALUES (9131, 'F-2026-09131', TO_DATE('2026-01-30', 'YYYY-MM-DD'), TO_DATE('2026-02-14', 'YYYY-MM-DD'), 56.63, 76.63, 'Anulada', 7131);
  INSERT INTO FACTURA VALUES (9132, 'F-2026-09132', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-04-18', 'YYYY-MM-DD'), 81.70, 91.70, 'Pagada', 7132);
  INSERT INTO FACTURA VALUES (9133, 'F-2026-09133', TO_DATE('2026-03-03', 'YYYY-MM-DD'), TO_DATE('2026-03-18', 'YYYY-MM-DD'), 160.77, 180.77, 'Pagada', 7133);
  INSERT INTO FACTURA VALUES (9134, 'F-2026-09134', TO_DATE('2026-01-21', 'YYYY-MM-DD'), TO_DATE('2026-02-20', 'YYYY-MM-DD'), 176.43, 196.43, 'Pagada', 7134);
  INSERT INTO FACTURA VALUES (9135, 'F-2026-09135', TO_DATE('2026-04-17', 'YYYY-MM-DD'), TO_DATE('2026-05-17', 'YYYY-MM-DD'), 81.33, 96.33, 'Pagada', 7135);
  INSERT INTO FACTURA VALUES (9136, 'F-2026-09136', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-04-18', 'YYYY-MM-DD'), 42.13, 62.13, 'Pagada', 7136);
  INSERT INTO FACTURA VALUES (9137, 'F-2026-09137', TO_DATE('2026-02-24', 'YYYY-MM-DD'), TO_DATE('2026-03-26', 'YYYY-MM-DD'), 92.20, 112.20, 'Emitida', 7137);
  INSERT INTO FACTURA VALUES (9138, 'F-2026-09138', TO_DATE('2026-02-23', 'YYYY-MM-DD'), TO_DATE('2026-04-09', 'YYYY-MM-DD'), 87.89, 107.89, 'Anulada', 7138);
  INSERT INTO FACTURA VALUES (9139, 'F-2026-09139', TO_DATE('2026-02-08', 'YYYY-MM-DD'), TO_DATE('2026-02-23', 'YYYY-MM-DD'), 145.24, 155.24, 'Pagada', 7139);
  INSERT INTO FACTURA VALUES (9140, 'F-2026-09140', TO_DATE('2026-03-12', 'YYYY-MM-DD'), TO_DATE('2026-04-11', 'YYYY-MM-DD'), 175.77, 190.77, 'Pagada', 7140);
  INSERT INTO FACTURA VALUES (9141, 'F-2026-09141', TO_DATE('2026-01-19', 'YYYY-MM-DD'), TO_DATE('2026-02-18', 'YYYY-MM-DD'), 69.41, 79.41, 'Emitida', 7141);
  INSERT INTO FACTURA VALUES (9142, 'F-2026-09142', TO_DATE('2026-04-13', 'YYYY-MM-DD'), TO_DATE('2026-04-28', 'YYYY-MM-DD'), 198.80, 208.80, 'Emitida', 7142);
  INSERT INTO FACTURA VALUES (9143, 'F-2026-09143', TO_DATE('2026-01-20', 'YYYY-MM-DD'), TO_DATE('2026-03-06', 'YYYY-MM-DD'), 195.27, 210.27, 'Anulada', 7143);
  INSERT INTO FACTURA VALUES (9144, 'F-2026-09144', TO_DATE('2026-04-20', 'YYYY-MM-DD'), TO_DATE('2026-05-05', 'YYYY-MM-DD'), 86.82, 101.82, 'Pagada', 7144);
  INSERT INTO FACTURA VALUES (9145, 'F-2026-09145', TO_DATE('2026-02-09', 'YYYY-MM-DD'), TO_DATE('2026-02-24', 'YYYY-MM-DD'), 102.77, 117.77, 'Anulada', 7145);
  INSERT INTO FACTURA VALUES (9146, 'F-2026-09146', TO_DATE('2026-02-14', 'YYYY-MM-DD'), TO_DATE('2026-03-01', 'YYYY-MM-DD'), 180.12, 195.12, 'Pagada', 7146);
  INSERT INTO FACTURA VALUES (9147, 'F-2026-09147', TO_DATE('2026-04-04', 'YYYY-MM-DD'), TO_DATE('2026-04-19', 'YYYY-MM-DD'), 125.10, 140.10, 'Pagada', 7147);
  INSERT INTO FACTURA VALUES (9148, 'F-2026-09148', TO_DATE('2026-04-17', 'YYYY-MM-DD'), TO_DATE('2026-05-17', 'YYYY-MM-DD'), 191.07, 211.07, 'Emitida', 7148);
  INSERT INTO FACTURA VALUES (9149, 'F-2026-09149', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-04-08', 'YYYY-MM-DD'), 202.94, 217.94, 'Emitida', 7149);
  INSERT INTO FACTURA VALUES (9150, 'F-2026-09150', TO_DATE('2026-02-16', 'YYYY-MM-DD'), TO_DATE('2026-03-03', 'YYYY-MM-DD'), 166.30, 186.30, 'Pagada', 7150);
  INSERT INTO FACTURA VALUES (9151, 'F-2026-09151', TO_DATE('2026-02-17', 'YYYY-MM-DD'), TO_DATE('2026-03-04', 'YYYY-MM-DD'), 145.42, 160.42, 'Anulada', 7151);
  INSERT INTO FACTURA VALUES (9152, 'F-2026-09152', TO_DATE('2026-04-09', 'YYYY-MM-DD'), TO_DATE('2026-05-09', 'YYYY-MM-DD'), 115.65, 125.65, 'Emitida', 7152);
  INSERT INTO FACTURA VALUES (9153, 'F-2026-09153', TO_DATE('2026-02-28', 'YYYY-MM-DD'), TO_DATE('2026-03-15', 'YYYY-MM-DD'), 199.11, 209.11, 'Pagada', 7153);
  INSERT INTO FACTURA VALUES (9154, 'F-2026-09154', TO_DATE('2026-03-12', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 61.27, 81.27, 'Pagada', 7154);
  INSERT INTO FACTURA VALUES (9155, 'F-2026-09155', TO_DATE('2026-02-19', 'YYYY-MM-DD'), TO_DATE('2026-04-05', 'YYYY-MM-DD'), 171.05, 191.05, 'Pagada', 7155);
  INSERT INTO FACTURA VALUES (9156, 'F-2026-09156', TO_DATE('2026-01-28', 'YYYY-MM-DD'), TO_DATE('2026-02-12', 'YYYY-MM-DD'), 196.22, 216.22, 'Pagada', 7156);
  INSERT INTO FACTURA VALUES (9157, 'F-2026-09157', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-05-08', 'YYYY-MM-DD'), 112.55, 127.55, 'Anulada', 7157);
  INSERT INTO FACTURA VALUES (9158, 'F-2026-09158', TO_DATE('2026-04-26', 'YYYY-MM-DD'), TO_DATE('2026-05-11', 'YYYY-MM-DD'), 125.79, 140.79, 'Pagada', 7158);
  INSERT INTO FACTURA VALUES (9159, 'F-2026-09159', TO_DATE('2026-03-01', 'YYYY-MM-DD'), TO_DATE('2026-03-16', 'YYYY-MM-DD'), 115.54, 135.54, 'Emitida', 7159);
  INSERT INTO FACTURA VALUES (9160, 'F-2026-09160', TO_DATE('2026-02-23', 'YYYY-MM-DD'), TO_DATE('2026-03-25', 'YYYY-MM-DD'), 224.22, 244.22, 'Pagada', 7160);
  INSERT INTO FACTURA VALUES (9161, 'F-2026-09161', TO_DATE('2026-04-06', 'YYYY-MM-DD'), TO_DATE('2026-04-21', 'YYYY-MM-DD'), 95.83, 105.83, 'Pagada', 7161);
  INSERT INTO FACTURA VALUES (9162, 'F-2026-09162', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-05-03', 'YYYY-MM-DD'), 56.66, 76.66, 'Emitida', 7162);
  INSERT INTO FACTURA VALUES (9163, 'F-2026-09163', TO_DATE('2026-03-22', 'YYYY-MM-DD'), TO_DATE('2026-04-06', 'YYYY-MM-DD'), 219.61, 229.61, 'Anulada', 7163);
  INSERT INTO FACTURA VALUES (9164, 'F-2026-09164', TO_DATE('2026-01-27', 'YYYY-MM-DD'), TO_DATE('2026-02-26', 'YYYY-MM-DD'), 115.42, 125.42, 'Anulada', 7164);
  INSERT INTO FACTURA VALUES (9165, 'F-2026-09165', TO_DATE('2026-02-18', 'YYYY-MM-DD'), TO_DATE('2026-03-05', 'YYYY-MM-DD'), 43.18, 58.18, 'Pagada', 7165);
  INSERT INTO FACTURA VALUES (9166, 'F-2026-09166', TO_DATE('2026-04-18', 'YYYY-MM-DD'), TO_DATE('2026-05-18', 'YYYY-MM-DD'), 213.91, 233.91, 'Pagada', 7166);
  INSERT INTO FACTURA VALUES (9167, 'F-2026-09167', TO_DATE('2026-02-13', 'YYYY-MM-DD'), TO_DATE('2026-03-15', 'YYYY-MM-DD'), 209.61, 219.61, 'Anulada', 7167);
  INSERT INTO FACTURA VALUES (9168, 'F-2026-09168', TO_DATE('2026-04-22', 'YYYY-MM-DD'), TO_DATE('2026-05-22', 'YYYY-MM-DD'), 182.25, 197.25, 'Emitida', 7168);
  INSERT INTO FACTURA VALUES (9169, 'F-2026-09169', TO_DATE('2026-04-12', 'YYYY-MM-DD'), TO_DATE('2026-04-27', 'YYYY-MM-DD'), 180.12, 190.12, 'Emitida', 7169);
  INSERT INTO FACTURA VALUES (9170, 'F-2026-09170', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-04-08', 'YYYY-MM-DD'), 125.10, 140.10, 'Anulada', 7170);
  INSERT INTO FACTURA VALUES (9171, 'F-2026-09171', TO_DATE('2026-02-15', 'YYYY-MM-DD'), TO_DATE('2026-03-02', 'YYYY-MM-DD'), 191.07, 211.07, 'Emitida', 7171);
  INSERT INTO FACTURA VALUES (9172, 'F-2026-09172', TO_DATE('2026-04-07', 'YYYY-MM-DD'), TO_DATE('2026-05-07', 'YYYY-MM-DD'), 202.94, 212.94, 'Emitida', 7172);
  INSERT INTO FACTURA VALUES (9173, 'F-2026-09173', TO_DATE('2026-01-30', 'YYYY-MM-DD'), TO_DATE('2026-02-14', 'YYYY-MM-DD'), 166.30, 186.30, 'Pagada', 7173);
  INSERT INTO FACTURA VALUES (9174, 'F-2026-09174', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-04-18', 'YYYY-MM-DD'), 145.42, 160.42, 'Emitida', 7174);
  INSERT INTO FACTURA VALUES (9175, 'F-2026-09175', TO_DATE('2026-03-03', 'YYYY-MM-DD'), TO_DATE('2026-04-02', 'YYYY-MM-DD'), 115.65, 125.65, 'Emitida', 7175);
  INSERT INTO FACTURA VALUES (9176, 'F-2026-09176', TO_DATE('2026-01-21', 'YYYY-MM-DD'), TO_DATE('2026-02-20', 'YYYY-MM-DD'), 199.11, 209.11, 'Pagada', 7176);
  INSERT INTO FACTURA VALUES (9177, 'F-2026-09177', TO_DATE('2026-04-17', 'YYYY-MM-DD'), TO_DATE('2026-05-17', 'YYYY-MM-DD'), 61.27, 81.27, 'Anulada', 7177);
  INSERT INTO FACTURA VALUES (9178, 'F-2026-09178', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-04-18', 'YYYY-MM-DD'), 171.05, 186.05, 'Pagada', 7178);
  INSERT INTO FACTURA VALUES (9179, 'F-2026-09179', TO_DATE('2026-02-24', 'YYYY-MM-DD'), TO_DATE('2026-03-11', 'YYYY-MM-DD'), 196.22, 216.22, 'Pagada', 7179);
  INSERT INTO FACTURA VALUES (9180, 'F-2026-09180', TO_DATE('2026-02-23', 'YYYY-MM-DD'), TO_DATE('2026-03-25', 'YYYY-MM-DD'), 112.55, 127.55, 'Pagada', 7180);
  INSERT INTO FACTURA VALUES (9181, 'F-2026-09181', TO_DATE('2026-02-08', 'YYYY-MM-DD'), TO_DATE('2026-03-10', 'YYYY-MM-DD'), 125.79, 140.79, 'Pagada', 7181);
  INSERT INTO FACTURA VALUES (9182, 'F-2026-09182', TO_DATE('2026-03-12', 'YYYY-MM-DD'), TO_DATE('2026-04-11', 'YYYY-MM-DD'), 115.54, 130.54, 'Emitida', 7182);
  INSERT INTO FACTURA VALUES (9183, 'F-2026-09183', TO_DATE('2026-01-19', 'YYYY-MM-DD'), TO_DATE('2026-03-05', 'YYYY-MM-DD'), 224.22, 244.22, 'Pagada', 7183);
  INSERT INTO FACTURA VALUES (9184, 'F-2026-09184', TO_DATE('2026-04-13', 'YYYY-MM-DD'), TO_DATE('2026-05-13', 'YYYY-MM-DD'), 95.83, 105.83, 'Emitida', 7184);
  INSERT INTO FACTURA VALUES (9185, 'F-2026-09185', TO_DATE('2026-03-18', 'YYYY-MM-DD'), TO_DATE('2026-04-17', 'YYYY-MM-DD'), 56.66, 76.66, 'Emitida', 7185);
  INSERT INTO FACTURA VALUES (9186, 'F-2026-09186', TO_DATE('2026-02-02', 'YYYY-MM-DD'), TO_DATE('2026-03-04', 'YYYY-MM-DD'), 219.61, 239.61, 'Emitida', 7186);
  INSERT INTO FACTURA VALUES (9187, 'F-2026-09187', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-05-18', 'YYYY-MM-DD'), 115.42, 125.42, 'Pagada', 7187);
  INSERT INTO FACTURA VALUES (9188, 'F-2026-09188', TO_DATE('2026-01-18', 'YYYY-MM-DD'), TO_DATE('2026-02-17', 'YYYY-MM-DD'), 43.18, 53.18, 'Anulada', 7188);
  INSERT INTO FACTURA VALUES (9189, 'F-2026-09189', TO_DATE('2026-04-05', 'YYYY-MM-DD'), TO_DATE('2026-05-05', 'YYYY-MM-DD'), 213.91, 233.91, 'Anulada', 7189);
  INSERT INTO FACTURA VALUES (9190, 'F-2026-09190', TO_DATE('2026-04-06', 'YYYY-MM-DD'), TO_DATE('2026-04-21', 'YYYY-MM-DD'), 209.61, 219.61, 'Pagada', 7190);
  INSERT INTO FACTURA VALUES (9191, 'F-2026-09191', TO_DATE('2026-01-20', 'YYYY-MM-DD'), TO_DATE('2026-03-06', 'YYYY-MM-DD'), 182.25, 197.25, 'Emitida', 7191);
  INSERT INTO FACTURA VALUES (9192, 'F-2026-09192', TO_DATE('2026-01-31', 'YYYY-MM-DD'), TO_DATE('2026-03-17', 'YYYY-MM-DD'), 180.12, 190.12, 'Pagada', 7192);
  INSERT INTO FACTURA VALUES (9193, 'F-2026-09193', TO_DATE('2026-03-08', 'YYYY-MM-DD'), TO_DATE('2026-04-22', 'YYYY-MM-DD'), 125.10, 140.10, 'Pagada', 7193);
  INSERT INTO FACTURA VALUES (9194, 'F-2026-09194', TO_DATE('2026-03-01', 'YYYY-MM-DD'), TO_DATE('2026-04-15', 'YYYY-MM-DD'), 191.07, 211.07, 'Emitida', 7194);
  INSERT INTO FACTURA VALUES (9195, 'F-2026-09195', TO_DATE('2026-01-16', 'YYYY-MM-DD'), TO_DATE('2026-02-15', 'YYYY-MM-DD'), 202.94, 212.94, 'Pagada', 7195);
  INSERT INTO FACTURA VALUES (9196, 'F-2026-09196', TO_DATE('2026-01-20', 'YYYY-MM-DD'), TO_DATE('2026-02-19', 'YYYY-MM-DD'), 166.30, 181.30, 'Pagada', 7196);
  INSERT INTO FACTURA VALUES (9197, 'F-2026-09197', TO_DATE('2026-04-12', 'YYYY-MM-DD'), TO_DATE('2026-04-27', 'YYYY-MM-DD'), 145.42, 160.42, 'Pagada', 7197);
  INSERT INTO FACTURA VALUES (9198, 'F-2026-09198', TO_DATE('2026-02-06', 'YYYY-MM-DD'), TO_DATE('2026-03-23', 'YYYY-MM-DD'), 115.65, 125.65, 'Emitida', 7198);
  INSERT INTO FACTURA VALUES (9199, 'F-2026-09199', TO_DATE('2026-03-28', 'YYYY-MM-DD'), TO_DATE('2026-05-12', 'YYYY-MM-DD'), 199.11, 209.11, 'Anulada', 7199);
  INSERT INTO FACTURA VALUES (9200, 'F-2026-09200', TO_DATE('2026-02-18', 'YYYY-MM-DD'), TO_DATE('2026-04-04', 'YYYY-MM-DD'), 61.27, 76.27, 'Pagada', 7200);
  COMMIT;
END;

--bloque 3
BEGIN
  INSERT INTO FACTURA VALUES (9201, 'F-2026-09201', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-05-01', 'YYYY-MM-DD'), 86.55, 101.55, 'Pagada', 7201);
  INSERT INTO FACTURA VALUES (9202, 'F-2026-09202', TO_DATE('2026-01-26', 'YYYY-MM-DD'), TO_DATE('2026-02-25', 'YYYY-MM-DD'), 117.56, 137.56, 'Anulada', 7202);
  INSERT INTO FACTURA VALUES (9203, 'F-2026-09203', TO_DATE('2026-01-13', 'YYYY-MM-DD'), TO_DATE('2026-02-12', 'YYYY-MM-DD'), 120.39, 140.39, 'Pagada', 7203);
  INSERT INTO FACTURA VALUES (9204, 'F-2026-09204', TO_DATE('2026-04-23', 'YYYY-MM-DD'), TO_DATE('2026-06-07', 'YYYY-MM-DD'), 43.21, 63.21, 'Anulada', 7204);
  INSERT INTO FACTURA VALUES (9205, 'F-2026-09205', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-16', 'YYYY-MM-DD'), 134.01, 149.01, 'Pagada', 7205);
  INSERT INTO FACTURA VALUES (9206, 'F-2026-09206', TO_DATE('2026-04-27', 'YYYY-MM-DD'), TO_DATE('2026-06-11', 'YYYY-MM-DD'), 189.84, 209.84, 'Anulada', 7206);
  INSERT INTO FACTURA VALUES (9207, 'F-2026-09207', TO_DATE('2026-02-09', 'YYYY-MM-DD'), TO_DATE('2026-02-24', 'YYYY-MM-DD'), 135.63, 155.63, 'Emitida', 7207);
  INSERT INTO FACTURA VALUES (9208, 'F-2026-09208', TO_DATE('2026-02-14', 'YYYY-MM-DD'), TO_DATE('2026-03-31', 'YYYY-MM-DD'), 219.25, 239.25, 'Pagada', 7208);
  INSERT INTO FACTURA VALUES (9209, 'F-2026-09209', TO_DATE('2026-03-10', 'YYYY-MM-DD'), TO_DATE('2026-04-09', 'YYYY-MM-DD'), 74.83, 89.83, 'Pagada', 7209);
  INSERT INTO FACTURA VALUES (9210, 'F-2026-09210', TO_DATE('2026-01-07', 'YYYY-MM-DD'), TO_DATE('2026-01-22', 'YYYY-MM-DD'), 104.37, 119.37, 'Anulada', 7210);
  INSERT INTO FACTURA VALUES (9211, 'F-2026-09211', TO_DATE('2026-01-09', 'YYYY-MM-DD'), TO_DATE('2026-01-24', 'YYYY-MM-DD'), 78.79, 98.79, 'Anulada', 7211);
  INSERT INTO FACTURA VALUES (9212, 'F-2026-09212', TO_DATE('2026-02-03', 'YYYY-MM-DD'), TO_DATE('2026-03-20', 'YYYY-MM-DD'), 191.89, 211.89, 'Emitida', 7212);
  INSERT INTO FACTURA VALUES (9213, 'F-2026-09213', TO_DATE('2026-04-12', 'YYYY-MM-DD'), TO_DATE('2026-04-27', 'YYYY-MM-DD'), 98.69, 118.69, 'Pagada', 7213);
  INSERT INTO FACTURA VALUES (9214, 'F-2026-09214', TO_DATE('2026-03-08', 'YYYY-MM-DD'), TO_DATE('2026-04-07', 'YYYY-MM-DD'), 102.99, 117.99, 'Anulada', 7214);
  INSERT INTO FACTURA VALUES (9215, 'F-2026-09215', TO_DATE('2026-01-25', 'YYYY-MM-DD'), TO_DATE('2026-02-24', 'YYYY-MM-DD'), 94.13, 109.13, 'Pagada', 7215);
  INSERT INTO FACTURA VALUES (9216, 'F-2026-09216', TO_DATE('2026-04-17', 'YYYY-MM-DD'), TO_DATE('2026-05-17', 'YYYY-MM-DD'), 84.64, 99.64, 'Anulada', 7216);
  INSERT INTO FACTURA VALUES (9217, 'F-2026-09217', TO_DATE('2026-03-21', 'YYYY-MM-DD'), TO_DATE('2026-04-20', 'YYYY-MM-DD'), 117.17, 127.17, 'Emitida', 7217);
  INSERT INTO FACTURA VALUES (9218, 'F-2026-09218', TO_DATE('2026-03-27', 'YYYY-MM-DD'), TO_DATE('2026-05-11', 'YYYY-MM-DD'), 204.35, 219.35, 'Pagada', 7218);
  INSERT INTO FACTURA VALUES (9219, 'F-2026-09219', TO_DATE('2026-03-09', 'YYYY-MM-DD'), TO_DATE('2026-04-23', 'YYYY-MM-DD'), 163.79, 178.79, 'Pagada', 7219);
  INSERT INTO FACTURA VALUES (9220, 'F-2026-09220', TO_DATE('2026-02-16', 'YYYY-MM-DD'), TO_DATE('2026-03-03', 'YYYY-MM-DD'), 208.97, 223.97, 'Pagada', 7220);
  INSERT INTO FACTURA VALUES (9221, 'F-2026-09221', TO_DATE('2026-04-16', 'YYYY-MM-DD'), TO_DATE('2026-05-31', 'YYYY-MM-DD'), 43.58, 53.58, 'Emitida', 7221);
  INSERT INTO FACTURA VALUES (9222, 'F-2026-09222', TO_DATE('2026-02-15', 'YYYY-MM-DD'), TO_DATE('2026-03-02', 'YYYY-MM-DD'), 122.62, 132.62, 'Emitida', 7222);
  INSERT INTO FACTURA VALUES (9223, 'F-2026-09223', TO_DATE('2026-02-01', 'YYYY-MM-DD'), TO_DATE('2026-02-16', 'YYYY-MM-DD'), 57.12, 67.12, 'Pagada', 7223);
  INSERT INTO FACTURA VALUES (9224, 'F-2026-09224', TO_DATE('2026-04-08', 'YYYY-MM-DD'), TO_DATE('2026-05-23', 'YYYY-MM-DD'), 108.72, 118.72, 'Anulada', 7224);
  INSERT INTO FACTURA VALUES (9225, 'F-2026-09225', TO_DATE('2026-03-22', 'YYYY-MM-DD'), TO_DATE('2026-04-21', 'YYYY-MM-DD'), 124.66, 134.66, 'Anulada', 7225);
  INSERT INTO FACTURA VALUES (9226, 'F-2026-09226', TO_DATE('2026-01-25', 'YYYY-MM-DD'), TO_DATE('2026-03-11', 'YYYY-MM-DD'), 163.20, 178.20, 'Pagada', 7226);
  INSERT INTO FACTURA VALUES (9227, 'F-2026-09227', TO_DATE('2026-02-04', 'YYYY-MM-DD'), TO_DATE('2026-03-21', 'YYYY-MM-DD'), 76.80, 96.80, 'Pagada', 7227);
  INSERT INTO FACTURA VALUES (9228, 'F-2026-09228', TO_DATE('2026-04-28', 'YYYY-MM-DD'), TO_DATE('2026-05-13', 'YYYY-MM-DD'), 130.96, 150.96, 'Anulada', 7228);
  INSERT INTO FACTURA VALUES (9229, 'F-2026-09229', TO_DATE('2026-03-18', 'YYYY-MM-DD'), TO_DATE('2026-04-17', 'YYYY-MM-DD'), 100.65, 120.65, 'Pagada', 7229);
  INSERT INTO FACTURA VALUES (9230, 'F-2026-09230', TO_DATE('2026-04-05', 'YYYY-MM-DD'), TO_DATE('2026-05-05', 'YYYY-MM-DD'), 194.27, 204.27, 'Anulada', 7230);
  INSERT INTO FACTURA VALUES (9231, 'F-2026-09231', TO_DATE('2026-01-13', 'YYYY-MM-DD'), TO_DATE('2026-02-12', 'YYYY-MM-DD'), 60.60, 70.60, 'Emitida', 7231);
  INSERT INTO FACTURA VALUES (9232, 'F-2026-09232', TO_DATE('2026-03-31', 'YYYY-MM-DD'), TO_DATE('2026-04-15', 'YYYY-MM-DD'), 181.65, 201.65, 'Emitida', 7232);
  INSERT INTO FACTURA VALUES (9233, 'F-2026-09233', TO_DATE('2026-03-30', 'YYYY-MM-DD'), TO_DATE('2026-05-14', 'YYYY-MM-DD'), 65.01, 75.01, 'Pagada', 7233);
  INSERT INTO FACTURA VALUES (9234, 'F-2026-09234', TO_DATE('2026-01-02', 'YYYY-MM-DD'), TO_DATE('2026-02-16', 'YYYY-MM-DD'), 107.40, 122.40, 'Emitida', 7234);
  INSERT INTO FACTURA VALUES (9235, 'F-2026-09235', TO_DATE('2026-02-01', 'YYYY-MM-DD'), TO_DATE('2026-02-16', 'YYYY-MM-DD'), 183.37, 193.37, 'Pagada', 7235);
  INSERT INTO FACTURA VALUES (9236, 'F-2026-09236', TO_DATE('2026-02-01', 'YYYY-MM-DD'), TO_DATE('2026-02-16', 'YYYY-MM-DD'), 64.00, 84.00, 'Anulada', 7236);
  INSERT INTO FACTURA VALUES (9237, 'F-2026-09237', TO_DATE('2026-02-20', 'YYYY-MM-DD'), TO_DATE('2026-03-22', 'YYYY-MM-DD'), 190.86, 210.86, 'Pagada', 7237);
  INSERT INTO FACTURA VALUES (9238, 'F-2026-09238', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-30', 'YYYY-MM-DD'), 59.25, 79.25, 'Pagada', 7238);
  INSERT INTO FACTURA VALUES (9239, 'F-2026-09239', TO_DATE('2026-02-09', 'YYYY-MM-DD'), TO_DATE('2026-03-11', 'YYYY-MM-DD'), 142.50, 162.50, 'Pagada', 7239);
  INSERT INTO FACTURA VALUES (9240, 'F-2026-09240', TO_DATE('2026-02-18', 'YYYY-MM-DD'), TO_DATE('2026-03-20', 'YYYY-MM-DD'), 95.76, 105.76, 'Pagada', 7240);
  INSERT INTO FACTURA VALUES (9241, 'F-2026-09241', TO_DATE('2026-02-17', 'YYYY-MM-DD'), TO_DATE('2026-04-03', 'YYYY-MM-DD'), 63.91, 73.91, 'Emitida', 7241);
  INSERT INTO FACTURA VALUES (9242, 'F-2026-09242', TO_DATE('2026-02-14', 'YYYY-MM-DD'), TO_DATE('2026-03-01', 'YYYY-MM-DD'), 64.85, 84.85, 'Emitida', 7242);
  INSERT INTO FACTURA VALUES (9243, 'F-2026-09243', TO_DATE('2026-04-12', 'YYYY-MM-DD'), TO_DATE('2026-05-12', 'YYYY-MM-DD'), 85.99, 95.99, 'Pagada', 7243);
  INSERT INTO FACTURA VALUES (9244, 'F-2026-09244', TO_DATE('2026-03-20', 'YYYY-MM-DD'), TO_DATE('2026-04-19', 'YYYY-MM-DD'), 163.16, 173.16, 'Pagada', 7244);
  INSERT INTO FACTURA VALUES (9245, 'F-2026-09245', TO_DATE('2026-02-01', 'YYYY-MM-DD'), TO_DATE('2026-02-16', 'YYYY-MM-DD'), 49.32, 59.32, 'Pagada', 7245);
  INSERT INTO FACTURA VALUES (9246, 'F-2026-09246', TO_DATE('2026-04-25', 'YYYY-MM-DD'), TO_DATE('2026-05-25', 'YYYY-MM-DD'), 202.61, 222.61, 'Pagada', 7246);
  INSERT INTO FACTURA VALUES (9247, 'F-2026-09247', TO_DATE('2026-01-27', 'YYYY-MM-DD'), TO_DATE('2026-02-11', 'YYYY-MM-DD'), 215.72, 225.72, 'Pagada', 7247);
  INSERT INTO FACTURA VALUES (9248, 'F-2026-09248', TO_DATE('2026-02-25', 'YYYY-MM-DD'), TO_DATE('2026-03-12', 'YYYY-MM-DD'), 63.51, 83.51, 'Pagada', 7248);
  INSERT INTO FACTURA VALUES (9249, 'F-2026-09249', TO_DATE('2026-01-21', 'YYYY-MM-DD'), TO_DATE('2026-02-20', 'YYYY-MM-DD'), 48.98, 68.98, 'Pagada', 7249);
  INSERT INTO FACTURA VALUES (9250, 'F-2026-09250', TO_DATE('2026-01-21', 'YYYY-MM-DD'), TO_DATE('2026-02-20', 'YYYY-MM-DD'), 119.31, 129.31, 'Pagada', 7250);
  INSERT INTO FACTURA VALUES (9251, 'F-2026-09251', TO_DATE('2026-01-01', 'YYYY-MM-DD'), TO_DATE('2026-01-31', 'YYYY-MM-DD'), 162.59, 177.59, 'Pagada', 7251);
  INSERT INTO FACTURA VALUES (9252, 'F-2026-09252', TO_DATE('2026-02-12', 'YYYY-MM-DD'), TO_DATE('2026-03-29', 'YYYY-MM-DD'), 129.32, 144.32, 'Pagada', 7252);
  INSERT INTO FACTURA VALUES (9253, 'F-2026-09253', TO_DATE('2026-04-17', 'YYYY-MM-DD'), TO_DATE('2026-05-02', 'YYYY-MM-DD'), 153.82, 168.82, 'Pagada', 7253);
  INSERT INTO FACTURA VALUES (9254, 'F-2026-09254', TO_DATE('2026-02-05', 'YYYY-MM-DD'), TO_DATE('2026-02-20', 'YYYY-MM-DD'), 118.88, 133.88, 'Anulada', 7254);
  INSERT INTO FACTURA VALUES (9255, 'F-2026-09255', TO_DATE('2026-02-17', 'YYYY-MM-DD'), TO_DATE('2026-04-03', 'YYYY-MM-DD'), 166.25, 181.25, 'Emitida', 7255);
  INSERT INTO FACTURA VALUES (9256, 'F-2026-09256', TO_DATE('2026-04-09', 'YYYY-MM-DD'), TO_DATE('2026-05-09', 'YYYY-MM-DD'), 99.52, 109.52, 'Pagada', 7256);
  INSERT INTO FACTURA VALUES (9257, 'F-2026-09257', TO_DATE('2026-03-06', 'YYYY-MM-DD'), TO_DATE('2026-04-20', 'YYYY-MM-DD'), 82.76, 102.76, 'Pagada', 7257);
  INSERT INTO FACTURA VALUES (9258, 'F-2026-09258', TO_DATE('2026-03-25', 'YYYY-MM-DD'), TO_DATE('2026-04-09', 'YYYY-MM-DD'), 198.86, 208.86, 'Pagada', 7258);
  INSERT INTO FACTURA VALUES (9259, 'F-2026-09259', TO_DATE('2026-02-17', 'YYYY-MM-DD'), TO_DATE('2026-03-04', 'YYYY-MM-DD'), 196.90, 211.90, 'Emitida', 7259);
  INSERT INTO FACTURA VALUES (9260, 'F-2026-09260', TO_DATE('2026-01-14', 'YYYY-MM-DD'), TO_DATE('2026-01-29', 'YYYY-MM-DD'), 172.74, 182.74, 'Pagada', 7260);
  INSERT INTO FACTURA VALUES (9261, 'F-2026-09261', TO_DATE('2026-04-02', 'YYYY-MM-DD'), TO_DATE('2026-05-02', 'YYYY-MM-DD'), 187.57, 202.57, 'Pagada', 7261);
  INSERT INTO FACTURA VALUES (9262, 'F-2026-09262', TO_DATE('2026-01-02', 'YYYY-MM-DD'), TO_DATE('2026-01-17', 'YYYY-MM-DD'), 46.80, 61.80, 'Pagada', 7262);
  INSERT INTO FACTURA VALUES (9263, 'F-2026-09263', TO_DATE('2026-04-26', 'YYYY-MM-DD'), TO_DATE('2026-05-26', 'YYYY-MM-DD'), 140.25, 160.25, 'Emitida', 7263);
  INSERT INTO FACTURA VALUES (9264, 'F-2026-09264', TO_DATE('2026-04-25', 'YYYY-MM-DD'), TO_DATE('2026-05-10', 'YYYY-MM-DD'), 207.96, 217.96, 'Pagada', 7264);
  INSERT INTO FACTURA VALUES (9265, 'F-2026-09265', TO_DATE('2026-01-31', 'YYYY-MM-DD'), TO_DATE('2026-03-17', 'YYYY-MM-DD'), 112.56, 127.56, 'Emitida', 7265);
  INSERT INTO FACTURA VALUES (9266, 'F-2026-09266', TO_DATE('2026-01-20', 'YYYY-MM-DD'), TO_DATE('2026-02-04', 'YYYY-MM-DD'), 42.09, 52.09, 'Anulada', 7266);
  INSERT INTO FACTURA VALUES (9267, 'F-2026-09267', TO_DATE('2026-04-28', 'YYYY-MM-DD'), TO_DATE('2026-05-28', 'YYYY-MM-DD'), 105.90, 125.90, 'Pagada', 7267);
  INSERT INTO FACTURA VALUES (9268, 'F-2026-09268', TO_DATE('2026-01-09', 'YYYY-MM-DD'), TO_DATE('2026-02-23', 'YYYY-MM-DD'), 117.24, 137.24, 'Pagada', 7268);
  INSERT INTO FACTURA VALUES (9269, 'F-2026-09269', TO_DATE('2026-02-01', 'YYYY-MM-DD'), TO_DATE('2026-03-18', 'YYYY-MM-DD'), 176.26, 186.26, 'Pagada', 7269);
  INSERT INTO FACTURA VALUES (9270, 'F-2026-09270', TO_DATE('2026-03-22', 'YYYY-MM-DD'), TO_DATE('2026-04-06', 'YYYY-MM-DD'), 139.11, 154.11, 'Anulada', 7270);
  INSERT INTO FACTURA VALUES (9271, 'F-2026-09271', TO_DATE('2026-02-02', 'YYYY-MM-DD'), TO_DATE('2026-02-17', 'YYYY-MM-DD'), 188.17, 198.17, 'Emitida', 7271);
  INSERT INTO FACTURA VALUES (9272, 'F-2026-09272', TO_DATE('2026-03-26', 'YYYY-MM-DD'), TO_DATE('2026-04-10', 'YYYY-MM-DD'), 221.82, 236.82, 'Emitida', 7272);
  INSERT INTO FACTURA VALUES (9273, 'F-2026-09273', TO_DATE('2026-04-07', 'YYYY-MM-DD'), TO_DATE('2026-04-22', 'YYYY-MM-DD'), 47.48, 62.48, 'Pagada', 7273);
  INSERT INTO FACTURA VALUES (9274, 'F-2026-09274', TO_DATE('2026-04-12', 'YYYY-MM-DD'), TO_DATE('2026-05-12', 'YYYY-MM-DD'), 139.39, 154.39, 'Pagada', 7274);
  INSERT INTO FACTURA VALUES (9275, 'F-2026-09275', TO_DATE('2026-03-15', 'YYYY-MM-DD'), TO_DATE('2026-03-30', 'YYYY-MM-DD'), 204.85, 224.85, 'Pagada', 7275);
  INSERT INTO FACTURA VALUES (9276, 'F-2026-09276', TO_DATE('2026-03-08', 'YYYY-MM-DD'), TO_DATE('2026-04-07', 'YYYY-MM-DD'), 79.29, 89.29, 'Pagada', 7276);
  INSERT INTO FACTURA VALUES (9277, 'F-2026-09277', TO_DATE('2026-02-09', 'YYYY-MM-DD'), TO_DATE('2026-03-26', 'YYYY-MM-DD'), 83.34, 98.34, 'Pagada', 7277);
  INSERT INTO FACTURA VALUES (9278, 'F-2026-09278', TO_DATE('2026-01-15', 'YYYY-MM-DD'), TO_DATE('2026-01-30', 'YYYY-MM-DD'), 179.05, 189.05, 'Emitida', 7278);
  INSERT INTO FACTURA VALUES (9279, 'F-2026-09279', TO_DATE('2026-02-15', 'YYYY-MM-DD'), TO_DATE('2026-03-02', 'YYYY-MM-DD'), 41.48, 61.48, 'Pagada', 7279);
  INSERT INTO FACTURA VALUES (9280, 'F-2026-09280', TO_DATE('2026-02-09', 'YYYY-MM-DD'), TO_DATE('2026-02-24', 'YYYY-MM-DD'), 162.59, 172.59, 'Anulada', 7280);
  INSERT INTO FACTURA VALUES (9281, 'F-2026-09281', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-04-16', 'YYYY-MM-DD'), 215.21, 230.21, 'Pagada', 7281);
  INSERT INTO FACTURA VALUES (9282, 'F-2026-09282', TO_DATE('2026-04-04', 'YYYY-MM-DD'), TO_DATE('2026-05-04', 'YYYY-MM-DD'), 130.50, 150.50, 'Emitida', 7282);
  INSERT INTO FACTURA VALUES (9283, 'F-2026-09283', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-30', 'YYYY-MM-DD'), 156.96, 166.96, 'Anulada', 7283);
  INSERT INTO FACTURA VALUES (9284, 'F-2026-09284', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-04-23', 'YYYY-MM-DD'), 109.78, 129.78, 'Pagada', 7284);
  INSERT INTO FACTURA VALUES (9285, 'F-2026-09285', TO_DATE('2026-04-11', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 75.36, 90.36, 'Emitida', 7285);
  INSERT INTO FACTURA VALUES (9286, 'F-2026-09286', TO_DATE('2026-04-27', 'YYYY-MM-DD'), TO_DATE('2026-06-11', 'YYYY-MM-DD'), 40.48, 50.48, 'Emitida', 7286);
  INSERT INTO FACTURA VALUES (9287, 'F-2026-09287', TO_DATE('2026-03-25', 'YYYY-MM-DD'), TO_DATE('2026-04-24', 'YYYY-MM-DD'), 44.39, 54.39, 'Pagada', 7287);
  INSERT INTO FACTURA VALUES (9288, 'F-2026-09288', TO_DATE('2026-02-02', 'YYYY-MM-DD'), TO_DATE('2026-02-17', 'YYYY-MM-DD'), 223.47, 233.47, 'Emitida', 7288);
  INSERT INTO FACTURA VALUES (9289, 'F-2026-09289', TO_DATE('2026-03-08', 'YYYY-MM-DD'), TO_DATE('2026-03-23', 'YYYY-MM-DD'), 140.21, 150.21, 'Anulada', 7289);
  INSERT INTO FACTURA VALUES (9290, 'F-2026-09290', TO_DATE('2026-02-12', 'YYYY-MM-DD'), TO_DATE('2026-02-27', 'YYYY-MM-DD'), 149.39, 159.39, 'Anulada', 7290);
  INSERT INTO FACTURA VALUES (9291, 'F-2026-09291', TO_DATE('2026-03-29', 'YYYY-MM-DD'), TO_DATE('2026-04-13', 'YYYY-MM-DD'), 84.32, 94.32, 'Anulada', 7291);
  INSERT INTO FACTURA VALUES (9292, 'F-2026-09292', TO_DATE('2026-03-10', 'YYYY-MM-DD'), TO_DATE('2026-03-25', 'YYYY-MM-DD'), 139.99, 154.99, 'Emitida', 7292);
  INSERT INTO FACTURA VALUES (9293, 'F-2026-09293', TO_DATE('2026-04-14', 'YYYY-MM-DD'), TO_DATE('2026-05-14', 'YYYY-MM-DD'), 60.02, 70.02, 'Pagada', 7293);
  INSERT INTO FACTURA VALUES (9294, 'F-2026-09294', TO_DATE('2026-01-21', 'YYYY-MM-DD'), TO_DATE('2026-03-07', 'YYYY-MM-DD'), 198.04, 213.04, 'Anulada', 7294);
  INSERT INTO FACTURA VALUES (9295, 'F-2026-09295', TO_DATE('2026-04-12', 'YYYY-MM-DD'), TO_DATE('2026-05-27', 'YYYY-MM-DD'), 166.64, 186.64, 'Pagada', 7295);
  INSERT INTO FACTURA VALUES (9296, 'F-2026-09296', TO_DATE('2026-03-29', 'YYYY-MM-DD'), TO_DATE('2026-04-13', 'YYYY-MM-DD'), 180.05, 195.05, 'Emitida', 7296);
  INSERT INTO FACTURA VALUES (9297, 'F-2026-09297', TO_DATE('2026-04-06', 'YYYY-MM-DD'), TO_DATE('2026-05-21', 'YYYY-MM-DD'), 69.87, 79.87, 'Pagada', 7297);
  INSERT INTO FACTURA VALUES (9298, 'F-2026-09298', TO_DATE('2026-04-28', 'YYYY-MM-DD'), TO_DATE('2026-05-28', 'YYYY-MM-DD'), 122.22, 137.22, 'Anulada', 7298);
  INSERT INTO FACTURA VALUES (9299, 'F-2026-09299', TO_DATE('2026-02-24', 'YYYY-MM-DD'), TO_DATE('2026-04-10', 'YYYY-MM-DD'), 221.30, 241.30, 'Emitida', 7299);
  INSERT INTO FACTURA VALUES (9300, 'F-2026-09300', TO_DATE('2026-03-26', 'YYYY-MM-DD'), TO_DATE('2026-04-10', 'YYYY-MM-DD'), 121.06, 136.06, 'Pagada', 7300);
  COMMIT;
END;

--bloque 4
BEGIN
  INSERT INTO FACTURA VALUES (9301, 'F-2026-09301', TO_DATE('2026-01-29', 'YYYY-MM-DD'), TO_DATE('2026-03-15', 'YYYY-MM-DD'), 141.01, 151.01, 'Pagada', 7301);
  INSERT INTO FACTURA VALUES (9302, 'F-2026-09302', TO_DATE('2026-01-07', 'YYYY-MM-DD'), TO_DATE('2026-02-21', 'YYYY-MM-DD'), 194.66, 204.66, 'Pagada', 7302);
  INSERT INTO FACTURA VALUES (9303, 'F-2026-09303', TO_DATE('2026-03-03', 'YYYY-MM-DD'), TO_DATE('2026-04-17', 'YYYY-MM-DD'), 188.29, 203.29, 'Pagada', 7303);
  INSERT INTO FACTURA VALUES (9304, 'F-2026-09304', TO_DATE('2026-01-05', 'YYYY-MM-DD'), TO_DATE('2026-01-20', 'YYYY-MM-DD'), 217.63, 232.63, 'Pagada', 7304);
  INSERT INTO FACTURA VALUES (9305, 'F-2026-09305', TO_DATE('2026-01-19', 'YYYY-MM-DD'), TO_DATE('2026-02-03', 'YYYY-MM-DD'), 155.54, 165.54, 'Pagada', 7305);
  INSERT INTO FACTURA VALUES (9306, 'F-2026-09306', TO_DATE('2026-01-27', 'YYYY-MM-DD'), TO_DATE('2026-02-11', 'YYYY-MM-DD'), 78.50, 88.50, 'Pagada', 7306);
  INSERT INTO FACTURA VALUES (9307, 'F-2026-09307', TO_DATE('2026-01-06', 'YYYY-MM-DD'), TO_DATE('2026-02-20', 'YYYY-MM-DD'), 217.68, 237.68, 'Pagada', 7307);
  INSERT INTO FACTURA VALUES (9308, 'F-2026-09308', TO_DATE('2026-02-20', 'YYYY-MM-DD'), TO_DATE('2026-03-07', 'YYYY-MM-DD'), 139.03, 149.03, 'Anulada', 7308);
  INSERT INTO FACTURA VALUES (9309, 'F-2026-09309', TO_DATE('2026-04-19', 'YYYY-MM-DD'), TO_DATE('2026-06-03', 'YYYY-MM-DD'), 73.99, 93.99, 'Anulada', 7309);
  INSERT INTO FACTURA VALUES (9310, 'F-2026-09310', TO_DATE('2026-01-11', 'YYYY-MM-DD'), TO_DATE('2026-02-10', 'YYYY-MM-DD'), 218.01, 228.01, 'Emitida', 7310);
  INSERT INTO FACTURA VALUES (9311, 'F-2026-09311', TO_DATE('2026-03-30', 'YYYY-MM-DD'), TO_DATE('2026-04-29', 'YYYY-MM-DD'), 67.81, 77.81, 'Pagada', 7311);
  INSERT INTO FACTURA VALUES (9312, 'F-2026-09312', TO_DATE('2026-03-01', 'YYYY-MM-DD'), TO_DATE('2026-04-15', 'YYYY-MM-DD'), 80.78, 90.78, 'Anulada', 7312);
  INSERT INTO FACTURA VALUES (9313, 'F-2026-09313', TO_DATE('2026-04-24', 'YYYY-MM-DD'), TO_DATE('2026-05-24', 'YYYY-MM-DD'), 181.79, 201.79, 'Pagada', 7313);
  INSERT INTO FACTURA VALUES (9314, 'F-2026-09314', TO_DATE('2026-03-18', 'YYYY-MM-DD'), TO_DATE('2026-04-17', 'YYYY-MM-DD'), 83.88, 103.88, 'Emitida', 7314);
  INSERT INTO FACTURA VALUES (9315, 'F-2026-09315', TO_DATE('2026-02-10', 'YYYY-MM-DD'), TO_DATE('2026-03-12', 'YYYY-MM-DD'), 119.39, 134.39, 'Pagada', 7315);
  INSERT INTO FACTURA VALUES (9316, 'F-2026-09316', TO_DATE('2026-04-12', 'YYYY-MM-DD'), TO_DATE('2026-05-12', 'YYYY-MM-DD'), 62.36, 82.36, 'Anulada', 7316);
  INSERT INTO FACTURA VALUES (9317, 'F-2026-09317', TO_DATE('2026-03-14', 'YYYY-MM-DD'), TO_DATE('2026-03-29', 'YYYY-MM-DD'), 93.41, 113.41, 'Pagada', 7317);
  INSERT INTO FACTURA VALUES (9318, 'F-2026-09318', TO_DATE('2026-01-22', 'YYYY-MM-DD'), TO_DATE('2026-02-21', 'YYYY-MM-DD'), 218.25, 238.25, 'Anulada', 7318);
  INSERT INTO FACTURA VALUES (9319, 'F-2026-09319', TO_DATE('2026-04-03', 'YYYY-MM-DD'), TO_DATE('2026-04-18', 'YYYY-MM-DD'), 41.32, 56.32, 'Pagada', 7319);
  INSERT INTO FACTURA VALUES (9320, 'F-2026-09320', TO_DATE('2026-04-17', 'YYYY-MM-DD'), TO_DATE('2026-05-17', 'YYYY-MM-DD'), 55.87, 65.87, 'Pagada', 7320);
  INSERT INTO FACTURA VALUES (9321, 'F-2026-09321', TO_DATE('2026-04-09', 'YYYY-MM-DD'), TO_DATE('2026-05-09', 'YYYY-MM-DD'), 188.99, 203.99, 'Pagada', 7321);
  INSERT INTO FACTURA VALUES (9322, 'F-2026-09322', TO_DATE('2026-03-12', 'YYYY-MM-DD'), TO_DATE('2026-03-27', 'YYYY-MM-DD'), 128.37, 148.37, 'Pagada', 7322);
  INSERT INTO FACTURA VALUES (9323, 'F-2026-09323', TO_DATE('2026-02-25', 'YYYY-MM-DD'), TO_DATE('2026-04-11', 'YYYY-MM-DD'), 79.46, 94.46, 'Anulada', 7323);
  INSERT INTO FACTURA VALUES (9324, 'F-2026-09324', TO_DATE('2026-02-13', 'YYYY-MM-DD'), TO_DATE('2026-02-28', 'YYYY-MM-DD'), 150.09, 160.09, 'Anulada', 7324);
  INSERT INTO FACTURA VALUES (9325, 'F-2026-09325', TO_DATE('2026-04-14', 'YYYY-MM-DD'), TO_DATE('2026-05-29', 'YYYY-MM-DD'), 106.61, 121.61, 'Pagada', 7325);
  INSERT INTO FACTURA VALUES (9326, 'F-2026-09326', TO_DATE('2026-04-12', 'YYYY-MM-DD'), TO_DATE('2026-05-27', 'YYYY-MM-DD'), 155.47, 165.47, 'Pagada', 7326);
  INSERT INTO FACTURA VALUES (9327, 'F-2026-09327', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-30', 'YYYY-MM-DD'), 75.88, 95.88, 'Anulada', 7327);
  INSERT INTO FACTURA VALUES (9328, 'F-2026-09328', TO_DATE('2026-03-04', 'YYYY-MM-DD'), TO_DATE('2026-03-19', 'YYYY-MM-DD'), 84.56, 99.56, 'Pagada', 7328);
  INSERT INTO FACTURA VALUES (9329, 'F-2026-09329', TO_DATE('2026-03-11', 'YYYY-MM-DD'), TO_DATE('2026-04-10', 'YYYY-MM-DD'), 130.17, 145.17, 'Anulada', 7329);
  INSERT INTO FACTURA VALUES (9330, 'F-2026-09330', TO_DATE('2026-04-19', 'YYYY-MM-DD'), TO_DATE('2026-05-04', 'YYYY-MM-DD'), 229.01, 244.01, 'Pagada', 7330);
  INSERT INTO FACTURA VALUES (9331, 'F-2026-09331', TO_DATE('2026-04-13', 'YYYY-MM-DD'), TO_DATE('2026-04-28', 'YYYY-MM-DD'), 100.40, 115.40, 'Pagada', 7331);
  INSERT INTO FACTURA VALUES (9332, 'F-2026-09332', TO_DATE('2026-04-09', 'YYYY-MM-DD'), TO_DATE('2026-04-24', 'YYYY-MM-DD'), 166.12, 176.12, 'Pagada', 7332);
  INSERT INTO FACTURA VALUES (9333, 'F-2026-09333', TO_DATE('2026-02-09', 'YYYY-MM-DD'), TO_DATE('2026-03-11', 'YYYY-MM-DD'), 137.85, 157.85, 'Pagada', 7333);
  INSERT INTO FACTURA VALUES (9334, 'F-2026-09334', TO_DATE('2026-03-07', 'YYYY-MM-DD'), TO_DATE('2026-04-21', 'YYYY-MM-DD'), 126.61, 146.61, 'Anulada', 7334);
  INSERT INTO FACTURA VALUES (9335, 'F-2026-09335', TO_DATE('2026-03-21', 'YYYY-MM-DD'), TO_DATE('2026-05-05', 'YYYY-MM-DD'), 206.83, 216.83, 'Pagada', 7335);
  INSERT INTO FACTURA VALUES (9336, 'F-2026-09336', TO_DATE('2026-01-27', 'YYYY-MM-DD'), TO_DATE('2026-03-13', 'YYYY-MM-DD'), 94.00, 114.00, 'Pagada', 7336);
  INSERT INTO FACTURA VALUES (9337, 'F-2026-09337', TO_DATE('2026-02-27', 'YYYY-MM-DD'), TO_DATE('2026-04-13', 'YYYY-MM-DD'), 85.23, 105.23, 'Emitida', 7337);
  INSERT INTO FACTURA VALUES (9338, 'F-2026-09338', TO_DATE('2026-04-05', 'YYYY-MM-DD'), TO_DATE('2026-05-05', 'YYYY-MM-DD'), 81.36, 96.36, 'Emitida', 7338);
  INSERT INTO FACTURA VALUES (9339, 'F-2026-09339', TO_DATE('2026-03-06', 'YYYY-MM-DD'), TO_DATE('2026-03-21', 'YYYY-MM-DD'), 199.87, 219.87, 'Anulada', 7339);
  INSERT INTO FACTURA VALUES (9340, 'F-2026-09340', TO_DATE('2026-01-25', 'YYYY-MM-DD'), TO_DATE('2026-02-24', 'YYYY-MM-DD'), 133.70, 143.70, 'Anulada', 7340);
  INSERT INTO FACTURA VALUES (9341, 'F-2026-09341', TO_DATE('2026-03-28', 'YYYY-MM-DD'), TO_DATE('2026-05-12', 'YYYY-MM-DD'), 53.84, 73.84, 'Emitida', 7341);
  INSERT INTO FACTURA VALUES (9342, 'F-2026-09342', TO_DATE('2026-04-24', 'YYYY-MM-DD'), TO_DATE('2026-05-09', 'YYYY-MM-DD'), 157.17, 167.17, 'Pagada', 7342);
  INSERT INTO FACTURA VALUES (9343, 'F-2026-09343', TO_DATE('2026-01-16', 'YYYY-MM-DD'), TO_DATE('2026-01-31', 'YYYY-MM-DD'), 227.50, 247.50, 'Pagada', 7343);
  INSERT INTO FACTURA VALUES (9344, 'F-2026-09344', TO_DATE('2026-01-01', 'YYYY-MM-DD'), TO_DATE('2026-01-16', 'YYYY-MM-DD'), 45.61, 55.61, 'Emitida', 7344);
  INSERT INTO FACTURA VALUES (9345, 'F-2026-09345', TO_DATE('2026-01-15', 'YYYY-MM-DD'), TO_DATE('2026-03-01', 'YYYY-MM-DD'), 107.17, 122.17, 'Pagada', 7345);
  INSERT INTO FACTURA VALUES (9346, 'F-2026-09346', TO_DATE('2026-04-02', 'YYYY-MM-DD'), TO_DATE('2026-05-02', 'YYYY-MM-DD'), 144.05, 154.05, 'Pagada', 7346);
  INSERT INTO FACTURA VALUES (9347, 'F-2026-09347', TO_DATE('2026-02-14', 'YYYY-MM-DD'), TO_DATE('2026-03-01', 'YYYY-MM-DD'), 81.66, 101.66, 'Pagada', 7347);
  INSERT INTO FACTURA VALUES (9348, 'F-2026-09348', TO_DATE('2026-03-17', 'YYYY-MM-DD'), TO_DATE('2026-04-01', 'YYYY-MM-DD'), 225.83, 240.83, 'Pagada', 7348);
  INSERT INTO FACTURA VALUES (9349, 'F-2026-09349', TO_DATE('2026-02-18', 'YYYY-MM-DD'), TO_DATE('2026-03-05', 'YYYY-MM-DD'), 173.41, 183.41, 'Pagada', 7349);
  INSERT INTO FACTURA VALUES (9350, 'F-2026-09350', TO_DATE('2026-02-08', 'YYYY-MM-DD'), TO_DATE('2026-03-10', 'YYYY-MM-DD'), 153.12, 163.12, 'Pagada', 7350);
  INSERT INTO FACTURA VALUES (9351, 'F-2026-09351', TO_DATE('2026-01-10', 'YYYY-MM-DD'), TO_DATE('2026-02-24', 'YYYY-MM-DD'), 147.56, 162.56, 'Pagada', 7351);
  INSERT INTO FACTURA VALUES (9352, 'F-2026-09352', TO_DATE('2026-01-28', 'YYYY-MM-DD'), TO_DATE('2026-03-14', 'YYYY-MM-DD'), 223.09, 243.09, 'Emitida', 7352);
  INSERT INTO FACTURA VALUES (9353, 'F-2026-09353', TO_DATE('2026-03-31', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 55.47, 65.47, 'Pagada', 7353);
  INSERT INTO FACTURA VALUES (9354, 'F-2026-09354', TO_DATE('2026-01-03', 'YYYY-MM-DD'), TO_DATE('2026-02-17', 'YYYY-MM-DD'), 43.44, 58.44, 'Pagada', 7354);
  INSERT INTO FACTURA VALUES (9355, 'F-2026-09355', TO_DATE('2026-01-06', 'YYYY-MM-DD'), TO_DATE('2026-02-05', 'YYYY-MM-DD'), 142.77, 162.77, 'Anulada', 7355);
  INSERT INTO FACTURA VALUES (9356, 'F-2026-09356', TO_DATE('2026-04-21', 'YYYY-MM-DD'), TO_DATE('2026-05-21', 'YYYY-MM-DD'), 86.71, 101.71, 'Emitida', 7356);
  INSERT INTO FACTURA VALUES (9357, 'F-2026-09357', TO_DATE('2026-03-08', 'YYYY-MM-DD'), TO_DATE('2026-03-23', 'YYYY-MM-DD'), 63.13, 73.13, 'Pagada', 7357);
  INSERT INTO FACTURA VALUES (9358, 'F-2026-09358', TO_DATE('2026-01-20', 'YYYY-MM-DD'), TO_DATE('2026-02-04', 'YYYY-MM-DD'), 188.50, 203.50, 'Pagada', 7358);
  INSERT INTO FACTURA VALUES (9359, 'F-2026-09359', TO_DATE('2026-03-15', 'YYYY-MM-DD'), TO_DATE('2026-04-14', 'YYYY-MM-DD'), 218.43, 238.43, 'Pagada', 7359);
  INSERT INTO FACTURA VALUES (9360, 'F-2026-09360', TO_DATE('2026-01-19', 'YYYY-MM-DD'), TO_DATE('2026-02-03', 'YYYY-MM-DD'), 199.02, 214.02, 'Pagada', 7360);
  INSERT INTO FACTURA VALUES (9361, 'F-2026-09361', TO_DATE('2026-01-19', 'YYYY-MM-DD'), TO_DATE('2026-02-03', 'YYYY-MM-DD'), 199.27, 219.27, 'Pagada', 7361);
  INSERT INTO FACTURA VALUES (9362, 'F-2026-09362', TO_DATE('2026-01-03', 'YYYY-MM-DD'), TO_DATE('2026-02-17', 'YYYY-MM-DD'), 140.03, 150.03, 'Pagada', 7362);
  INSERT INTO FACTURA VALUES (9363, 'F-2026-09363', TO_DATE('2026-02-11', 'YYYY-MM-DD'), TO_DATE('2026-03-28', 'YYYY-MM-DD'), 79.33, 94.33, 'Anulada', 7363);
  INSERT INTO FACTURA VALUES (9364, 'F-2026-09364', TO_DATE('2026-04-17', 'YYYY-MM-DD'), TO_DATE('2026-06-01', 'YYYY-MM-DD'), 93.13, 108.13, 'Pagada', 7364);
  INSERT INTO FACTURA VALUES (9365, 'F-2026-09365', TO_DATE('2026-04-14', 'YYYY-MM-DD'), TO_DATE('2026-05-14', 'YYYY-MM-DD'), 209.03, 224.03, 'Pagada', 7365);
  INSERT INTO FACTURA VALUES (9366, 'F-2026-09366', TO_DATE('2026-02-11', 'YYYY-MM-DD'), TO_DATE('2026-03-28', 'YYYY-MM-DD'), 63.27, 83.27, 'Pagada', 7366);
  INSERT INTO FACTURA VALUES (9367, 'F-2026-09367', TO_DATE('2026-03-06', 'YYYY-MM-DD'), TO_DATE('2026-03-21', 'YYYY-MM-DD'), 118.94, 128.94, 'Pagada', 7367);
  INSERT INTO FACTURA VALUES (9368, 'F-2026-09368', TO_DATE('2026-03-19', 'YYYY-MM-DD'), TO_DATE('2026-04-18', 'YYYY-MM-DD'), 67.02, 82.02, 'Pagada', 7368);
  INSERT INTO FACTURA VALUES (9369, 'F-2026-09369', TO_DATE('2026-03-23', 'YYYY-MM-DD'), TO_DATE('2026-04-07', 'YYYY-MM-DD'), 185.93, 195.93, 'Anulada', 7369);
  INSERT INTO FACTURA VALUES (9370, 'F-2026-09370', TO_DATE('2026-02-10', 'YYYY-MM-DD'), TO_DATE('2026-02-25', 'YYYY-MM-DD'), 157.83, 177.83, 'Emitida', 7370);
  INSERT INTO FACTURA VALUES (9371, 'F-2026-09371', TO_DATE('2026-01-07', 'YYYY-MM-DD'), TO_DATE('2026-01-22', 'YYYY-MM-DD'), 162.42, 182.42, 'Emitida', 7371);
  INSERT INTO FACTURA VALUES (9372, 'F-2026-09372', TO_DATE('2026-03-11', 'YYYY-MM-DD'), TO_DATE('2026-04-10', 'YYYY-MM-DD'), 106.84, 126.84, 'Pagada', 7372);
  INSERT INTO FACTURA VALUES (9373, 'F-2026-09373', TO_DATE('2026-03-16', 'YYYY-MM-DD'), TO_DATE('2026-03-31', 'YYYY-MM-DD'), 181.90, 191.90, 'Pagada', 7373);
  INSERT INTO FACTURA VALUES (9374, 'F-2026-09374', TO_DATE('2026-02-08', 'YYYY-MM-DD'), TO_DATE('2026-03-25', 'YYYY-MM-DD'), 63.26, 73.26, 'Pagada', 7374);
  INSERT INTO FACTURA VALUES (9375, 'F-2026-09375', TO_DATE('2026-04-22', 'YYYY-MM-DD'), TO_DATE('2026-05-22', 'YYYY-MM-DD'), 69.99, 84.99, 'Pagada', 7375);
  INSERT INTO FACTURA VALUES (9376, 'F-2026-09376', TO_DATE('2026-02-27', 'YYYY-MM-DD'), TO_DATE('2026-03-29', 'YYYY-MM-DD'), 91.02, 111.02, 'Anulada', 7376);
  INSERT INTO FACTURA VALUES (9377, 'F-2026-09377', TO_DATE('2026-02-04', 'YYYY-MM-DD'), TO_DATE('2026-03-21', 'YYYY-MM-DD'), 212.33, 232.33, 'Anulada', 7377);
  INSERT INTO FACTURA VALUES (9378, 'F-2026-09378', TO_DATE('2026-03-28', 'YYYY-MM-DD'), TO_DATE('2026-04-27', 'YYYY-MM-DD'), 104.41, 124.41, 'Pagada', 7378);
  INSERT INTO FACTURA VALUES (9379, 'F-2026-09379', TO_DATE('2026-03-31', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 106.03, 126.03, 'Pagada', 7379);
  INSERT INTO FACTURA VALUES (9380, 'F-2026-09380', TO_DATE('2026-04-27', 'YYYY-MM-DD'), TO_DATE('2026-06-11', 'YYYY-MM-DD'), 53.43, 63.43, 'Pagada', 7380);
  INSERT INTO FACTURA VALUES (9381, 'F-2026-09381', TO_DATE('2026-04-05', 'YYYY-MM-DD'), TO_DATE('2026-04-20', 'YYYY-MM-DD'), 161.16, 176.16, 'Emitida', 7381);
  INSERT INTO FACTURA VALUES (9382, 'F-2026-09382', TO_DATE('2026-02-08', 'YYYY-MM-DD'), TO_DATE('2026-03-10', 'YYYY-MM-DD'), 196.61, 216.61, 'Pagada', 7382);
  INSERT INTO FACTURA VALUES (9383, 'F-2026-09383', TO_DATE('2026-01-24', 'YYYY-MM-DD'), TO_DATE('2026-02-23', 'YYYY-MM-DD'), 50.40, 70.40, 'Pagada', 7383);
  INSERT INTO FACTURA VALUES (9384, 'F-2026-09384', TO_DATE('2026-01-13', 'YYYY-MM-DD'), TO_DATE('2026-01-28', 'YYYY-MM-DD'), 88.74, 103.74, 'Anulada', 7384);
  INSERT INTO FACTURA VALUES (9385, 'F-2026-09385', TO_DATE('2026-03-31', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 158.10, 173.10, 'Emitida', 7385);
  INSERT INTO FACTURA VALUES (9386, 'F-2026-09386', TO_DATE('2026-01-01', 'YYYY-MM-DD'), TO_DATE('2026-01-16', 'YYYY-MM-DD'), 65.38, 75.38, 'Pagada', 7386);
  INSERT INTO FACTURA VALUES (9387, 'F-2026-09387', TO_DATE('2026-01-27', 'YYYY-MM-DD'), TO_DATE('2026-03-13', 'YYYY-MM-DD'), 46.33, 66.33, 'Pagada', 7387);
  INSERT INTO FACTURA VALUES (9388, 'F-2026-09388', TO_DATE('2026-02-18', 'YYYY-MM-DD'), TO_DATE('2026-04-04', 'YYYY-MM-DD'), 152.27, 162.27, 'Emitida', 7388);
  INSERT INTO FACTURA VALUES (9389, 'F-2026-09389', TO_DATE('2026-03-16', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 43.85, 53.85, 'Pagada', 7389);
  INSERT INTO FACTURA VALUES (9390, 'F-2026-09390', TO_DATE('2026-02-04', 'YYYY-MM-DD'), TO_DATE('2026-02-19', 'YYYY-MM-DD'), 56.03, 66.03, 'Pagada', 7390);
  INSERT INTO FACTURA VALUES (9391, 'F-2026-09391', TO_DATE('2026-02-07', 'YYYY-MM-DD'), TO_DATE('2026-02-22', 'YYYY-MM-DD'), 69.17, 89.17, 'Emitida', 7391);
  INSERT INTO FACTURA VALUES (9392, 'F-2026-09392', TO_DATE('2026-03-23', 'YYYY-MM-DD'), TO_DATE('2026-05-07', 'YYYY-MM-DD'), 100.90, 120.90, 'Pagada', 7392);
  INSERT INTO FACTURA VALUES (9393, 'F-2026-09393', TO_DATE('2026-01-21', 'YYYY-MM-DD'), TO_DATE('2026-02-20', 'YYYY-MM-DD'), 174.43, 189.43, 'Pagada', 7393);
  INSERT INTO FACTURA VALUES (9394, 'F-2026-09394', TO_DATE('2026-04-07', 'YYYY-MM-DD'), TO_DATE('2026-05-07', 'YYYY-MM-DD'), 50.37, 65.37, 'Pagada', 7394);
  INSERT INTO FACTURA VALUES (9395, 'F-2026-09395', TO_DATE('2026-01-01', 'YYYY-MM-DD'), TO_DATE('2026-01-31', 'YYYY-MM-DD'), 173.32, 193.32, 'Pagada', 7395);
  INSERT INTO FACTURA VALUES (9396, 'F-2026-09396', TO_DATE('2026-01-25', 'YYYY-MM-DD'), TO_DATE('2026-02-09', 'YYYY-MM-DD'), 124.67, 144.67, 'Anulada', 7396);
  INSERT INTO FACTURA VALUES (9397, 'F-2026-09397', TO_DATE('2026-03-29', 'YYYY-MM-DD'), TO_DATE('2026-04-28', 'YYYY-MM-DD'), 219.60, 229.60, 'Emitida', 7397);
  INSERT INTO FACTURA VALUES (9398, 'F-2026-09398', TO_DATE('2026-04-18', 'YYYY-MM-DD'), TO_DATE('2026-05-03', 'YYYY-MM-DD'), 175.18, 190.18, 'Pagada', 7398);
  INSERT INTO FACTURA VALUES (9399, 'F-2026-09399', TO_DATE('2026-02-22', 'YYYY-MM-DD'), TO_DATE('2026-03-24', 'YYYY-MM-DD'), 218.15, 228.15, 'Pagada', 7399);
  INSERT INTO FACTURA VALUES (9400, 'F-2026-09400', TO_DATE('2026-01-28', 'YYYY-MM-DD'), TO_DATE('2026-02-27', 'YYYY-MM-DD'), 164.06, 179.06, 'Pagada', 7400);
  COMMIT;
END;


--bloque 5
BEGIN
  INSERT INTO FACTURA VALUES (9401, 'F-2026-09401', TO_DATE('2026-01-21', 'YYYY-MM-DD'), TO_DATE('2026-02-20', 'YYYY-MM-DD'), 87.52, 102.52, 'Pagada', 7401);
  INSERT INTO FACTURA VALUES (9402, 'F-2026-09402', TO_DATE('2026-04-10', 'YYYY-MM-DD'), TO_DATE('2026-04-25', 'YYYY-MM-DD'), 219.77, 229.77, 'Pagada', 7402);
  INSERT INTO FACTURA VALUES (9403, 'F-2026-09403', TO_DATE('2026-02-02', 'YYYY-MM-DD'), TO_DATE('2026-03-19', 'YYYY-MM-DD'), 202.81, 217.81, 'Pagada', 7403);
  INSERT INTO FACTURA VALUES (9404, 'F-2026-09404', TO_DATE('2026-03-09', 'YYYY-MM-DD'), TO_DATE('2026-04-23', 'YYYY-MM-DD'), 65.05, 80.05, 'Pagada', 7404);
  INSERT INTO FACTURA VALUES (9405, 'F-2026-09405', TO_DATE('2026-04-05', 'YYYY-MM-DD'), TO_DATE('2026-05-05', 'YYYY-MM-DD'), 88.72, 103.72, 'Pagada', 7405);
  INSERT INTO FACTURA VALUES (9406, 'F-2026-09406', TO_DATE('2026-03-05', 'YYYY-MM-DD'), TO_DATE('2026-04-04', 'YYYY-MM-DD'), 208.91, 223.91, 'Emitida', 7406);
  INSERT INTO FACTURA VALUES (9407, 'F-2026-09407', TO_DATE('2026-02-04', 'YYYY-MM-DD'), TO_DATE('2026-02-19', 'YYYY-MM-DD'), 202.85, 222.85, 'Anulada', 7407);
  INSERT INTO FACTURA VALUES (9408, 'F-2026-09408', TO_DATE('2026-03-02', 'YYYY-MM-DD'), TO_DATE('2026-04-16', 'YYYY-MM-DD'), 74.12, 89.12, 'Anulada', 7408);
  INSERT INTO FACTURA VALUES (9409, 'F-2026-09409', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-05-08', 'YYYY-MM-DD'), 186.63, 196.63, 'Pagada', 7409);
  INSERT INTO FACTURA VALUES (9410, 'F-2026-09410', TO_DATE('2026-03-25', 'YYYY-MM-DD'), TO_DATE('2026-04-24', 'YYYY-MM-DD'), 151.58, 161.58, 'Anulada', 7410);
  INSERT INTO FACTURA VALUES (9411, 'F-2026-09411', TO_DATE('2026-04-01', 'YYYY-MM-DD'), TO_DATE('2026-05-01', 'YYYY-MM-DD'), 205.13, 215.13, 'Pagada', 7411);
  INSERT INTO FACTURA VALUES (9412, 'F-2026-09412', TO_DATE('2026-01-25', 'YYYY-MM-DD'), TO_DATE('2026-02-24', 'YYYY-MM-DD'), 100.57, 120.57, 'Emitida', 7412);
  INSERT INTO FACTURA VALUES (9413, 'F-2026-09413', TO_DATE('2026-04-04', 'YYYY-MM-DD'), TO_DATE('2026-04-19', 'YYYY-MM-DD'), 93.35, 103.35, 'Emitida', 7413);
  INSERT INTO FACTURA VALUES (9414, 'F-2026-09414', TO_DATE('2026-02-15', 'YYYY-MM-DD'), TO_DATE('2026-04-01', 'YYYY-MM-DD'), 173.51, 193.51, 'Pagada', 7414);
  INSERT INTO FACTURA VALUES (9415, 'F-2026-09415', TO_DATE('2026-01-27', 'YYYY-MM-DD'), TO_DATE('2026-02-26', 'YYYY-MM-DD'), 151.33, 166.33, 'Pagada', 7415);
  INSERT INTO FACTURA VALUES (9416, 'F-2026-09416', TO_DATE('2026-01-05', 'YYYY-MM-DD'), TO_DATE('2026-02-19', 'YYYY-MM-DD'), 191.93, 211.93, 'Emitida', 7416);
  INSERT INTO FACTURA VALUES (9417, 'F-2026-09417', TO_DATE('2026-04-16', 'YYYY-MM-DD'), TO_DATE('2026-05-16', 'YYYY-MM-DD'), 219.78, 239.78, 'Emitida', 7417);
  INSERT INTO FACTURA VALUES (9418, 'F-2026-09418', TO_DATE('2026-01-12', 'YYYY-MM-DD'), TO_DATE('2026-01-27', 'YYYY-MM-DD'), 225.23, 235.23, 'Pagada', 7418);
  INSERT INTO FACTURA VALUES (9419, 'F-2026-09419', TO_DATE('2026-04-04', 'YYYY-MM-DD'), TO_DATE('2026-05-04', 'YYYY-MM-DD'), 156.38, 166.38, 'Emitida', 7419);
  INSERT INTO FACTURA VALUES (9420, 'F-2026-09420', TO_DATE('2026-01-04', 'YYYY-MM-DD'), TO_DATE('2026-02-03', 'YYYY-MM-DD'), 155.73, 170.73, 'Pagada', 7420);
  INSERT INTO FACTURA VALUES (9421, 'F-2026-09421', TO_DATE('2026-03-13', 'YYYY-MM-DD'), TO_DATE('2026-03-28', 'YYYY-MM-DD'), 135.27, 155.27, 'Pagada', 7421);
  INSERT INTO FACTURA VALUES (9422, 'F-2026-09422', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-05-08', 'YYYY-MM-DD'), 182.19, 192.19, 'Pagada', 7422);
  INSERT INTO FACTURA VALUES (9423, 'F-2026-09423', TO_DATE('2026-03-15', 'YYYY-MM-DD'), TO_DATE('2026-04-14', 'YYYY-MM-DD'), 79.27, 99.27, 'Pagada', 7423);
  INSERT INTO FACTURA VALUES (9424, 'F-2026-09424', TO_DATE('2026-04-17', 'YYYY-MM-DD'), TO_DATE('2026-05-02', 'YYYY-MM-DD'), 62.98, 77.98, 'Emitida', 7424);
  INSERT INTO FACTURA VALUES (9425, 'F-2026-09425', TO_DATE('2026-03-20', 'YYYY-MM-DD'), TO_DATE('2026-04-04', 'YYYY-MM-DD'), 69.38, 79.38, 'Pagada', 7425);
  INSERT INTO FACTURA VALUES (9426, 'F-2026-09426', TO_DATE('2026-04-09', 'YYYY-MM-DD'), TO_DATE('2026-05-24', 'YYYY-MM-DD'), 196.78, 216.78, 'Pagada', 7426);
  INSERT INTO FACTURA VALUES (9427, 'F-2026-09427', TO_DATE('2026-02-08', 'YYYY-MM-DD'), TO_DATE('2026-02-23', 'YYYY-MM-DD'), 208.91, 228.91, 'Emitida', 7427);
  INSERT INTO FACTURA VALUES (9428, 'F-2026-09428', TO_DATE('2026-02-14', 'YYYY-MM-DD'), TO_DATE('2026-03-31', 'YYYY-MM-DD'), 157.81, 172.81, 'Pagada', 7428);
  INSERT INTO FACTURA VALUES (9429, 'F-2026-09429', TO_DATE('2026-04-18', 'YYYY-MM-DD'), TO_DATE('2026-06-02', 'YYYY-MM-DD'), 94.02, 109.02, 'Emitida', 7429);
  INSERT INTO FACTURA VALUES (9430, 'F-2026-09430', TO_DATE('2026-01-06', 'YYYY-MM-DD'), TO_DATE('2026-02-20', 'YYYY-MM-DD'), 115.38, 125.38, 'Pagada', 7430);
  INSERT INTO FACTURA VALUES (9431, 'F-2026-09431', TO_DATE('2026-04-19', 'YYYY-MM-DD'), TO_DATE('2026-05-19', 'YYYY-MM-DD'), 171.04, 181.04, 'Pagada', 7431);
  INSERT INTO FACTURA VALUES (9432, 'F-2026-09432', TO_DATE('2026-04-23', 'YYYY-MM-DD'), TO_DATE('2026-06-07', 'YYYY-MM-DD'), 152.97, 162.97, 'Anulada', 7432);
  INSERT INTO FACTURA VALUES (9433, 'F-2026-09433', TO_DATE('2026-01-20', 'YYYY-MM-DD'), TO_DATE('2026-02-19', 'YYYY-MM-DD'), 130.01, 145.01, 'Pagada', 7433);
  INSERT INTO FACTURA VALUES (9434, 'F-2026-09434', TO_DATE('2026-02-11', 'YYYY-MM-DD'), TO_DATE('2026-02-26', 'YYYY-MM-DD'), 87.44, 107.44, 'Emitida', 7434);
  INSERT INTO FACTURA VALUES (9435, 'F-2026-09435', TO_DATE('2026-02-18', 'YYYY-MM-DD'), TO_DATE('2026-03-20', 'YYYY-MM-DD'), 77.67, 92.67, 'Anulada', 7435);
  INSERT INTO FACTURA VALUES (9436, 'F-2026-09436', TO_DATE('2026-01-13', 'YYYY-MM-DD'), TO_DATE('2026-02-27', 'YYYY-MM-DD'), 167.98, 177.98, 'Pagada', 7436);
  INSERT INTO FACTURA VALUES (9437, 'F-2026-09437', TO_DATE('2026-04-13', 'YYYY-MM-DD'), TO_DATE('2026-05-13', 'YYYY-MM-DD'), 42.77, 62.77, 'Pagada', 7437);
  INSERT INTO FACTURA VALUES (9438, 'F-2026-09438', TO_DATE('2026-02-24', 'YYYY-MM-DD'), TO_DATE('2026-03-26', 'YYYY-MM-DD'), 49.50, 69.50, 'Pagada', 7438);
  INSERT INTO FACTURA VALUES (9439, 'F-2026-09439', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 67.65, 87.65, 'Pagada', 7439);
  INSERT INTO FACTURA VALUES (9440, 'F-2026-09440', TO_DATE('2026-02-23', 'YYYY-MM-DD'), TO_DATE('2026-04-09', 'YYYY-MM-DD'), 107.18, 117.18, 'Anulada', 7440);
  INSERT INTO FACTURA VALUES (9441, 'F-2026-09441', TO_DATE('2026-01-27', 'YYYY-MM-DD'), TO_DATE('2026-03-13', 'YYYY-MM-DD'), 229.00, 244.00, 'Emitida', 7441);
  INSERT INTO FACTURA VALUES (9442, 'F-2026-09442', TO_DATE('2026-02-21', 'YYYY-MM-DD'), TO_DATE('2026-03-23', 'YYYY-MM-DD'), 42.81, 52.81, 'Pagada', 7442);
  INSERT INTO FACTURA VALUES (9443, 'F-2026-09443', TO_DATE('2026-01-28', 'YYYY-MM-DD'), TO_DATE('2026-02-12', 'YYYY-MM-DD'), 106.71, 126.71, 'Emitida', 7443);
  INSERT INTO FACTURA VALUES (9444, 'F-2026-09444', TO_DATE('2026-02-12', 'YYYY-MM-DD'), TO_DATE('2026-02-27', 'YYYY-MM-DD'), 43.31, 63.31, 'Anulada', 7444);
  INSERT INTO FACTURA VALUES (9445, 'F-2026-09445', TO_DATE('2026-01-10', 'YYYY-MM-DD'), TO_DATE('2026-02-24', 'YYYY-MM-DD'), 85.94, 105.94, 'Pagada', 7445);
  INSERT INTO FACTURA VALUES (9446, 'F-2026-09446', TO_DATE('2026-02-08', 'YYYY-MM-DD'), TO_DATE('2026-03-10', 'YYYY-MM-DD'), 44.78, 54.78, 'Pagada', 7446);
  INSERT INTO FACTURA VALUES (9447, 'F-2026-09447', TO_DATE('2026-01-03', 'YYYY-MM-DD'), TO_DATE('2026-02-17', 'YYYY-MM-DD'), 154.46, 169.46, 'Pagada', 7447);
  INSERT INTO FACTURA VALUES (9448, 'F-2026-09448', TO_DATE('2026-02-25', 'YYYY-MM-DD'), TO_DATE('2026-03-12', 'YYYY-MM-DD'), 118.02, 138.02, 'Pagada', 7448);
  INSERT INTO FACTURA VALUES (9449, 'F-2026-09449', TO_DATE('2026-02-09', 'YYYY-MM-DD'), TO_DATE('2026-03-26', 'YYYY-MM-DD'), 84.80, 99.80, 'Emitida', 7449);
  INSERT INTO FACTURA VALUES (9450, 'F-2026-09450', TO_DATE('2026-03-24', 'YYYY-MM-DD'), TO_DATE('2026-04-08', 'YYYY-MM-DD'), 142.91, 157.91, 'Emitida', 7450);
  INSERT INTO FACTURA VALUES (9451, 'F-2026-09451', TO_DATE('2026-04-24', 'YYYY-MM-DD'), TO_DATE('2026-05-09', 'YYYY-MM-DD'), 139.37, 159.37, 'Pagada', 7451);
  INSERT INTO FACTURA VALUES (9452, 'F-2026-09452', TO_DATE('2026-02-16', 'YYYY-MM-DD'), TO_DATE('2026-03-18', 'YYYY-MM-DD'), 198.05, 213.05, 'Pagada', 7452);
  INSERT INTO FACTURA VALUES (9453, 'F-2026-09453', TO_DATE('2026-01-05', 'YYYY-MM-DD'), TO_DATE('2026-02-04', 'YYYY-MM-DD'), 51.89, 61.89, 'Pagada', 7453);
  INSERT INTO FACTURA VALUES (9454, 'F-2026-09454', TO_DATE('2026-04-16', 'YYYY-MM-DD'), TO_DATE('2026-05-01', 'YYYY-MM-DD'), 144.30, 159.30, 'Pagada', 7454);
  INSERT INTO FACTURA VALUES (9455, 'F-2026-09455', TO_DATE('2026-02-17', 'YYYY-MM-DD'), TO_DATE('2026-03-04', 'YYYY-MM-DD'), 82.34, 102.34, 'Anulada', 7455);
  INSERT INTO FACTURA VALUES (9456, 'F-2026-09456', TO_DATE('2026-01-08', 'YYYY-MM-DD'), TO_DATE('2026-02-22', 'YYYY-MM-DD'), 189.08, 199.08, 'Pagada', 7456);
  INSERT INTO FACTURA VALUES (9457, 'F-2026-09457', TO_DATE('2026-02-22', 'YYYY-MM-DD'), TO_DATE('2026-04-08', 'YYYY-MM-DD'), 151.55, 166.55, 'Emitida', 7457);
  INSERT INTO FACTURA VALUES (9458, 'F-2026-09458', TO_DATE('2026-01-06', 'YYYY-MM-DD'), TO_DATE('2026-02-05', 'YYYY-MM-DD'), 52.15, 67.15, 'Pagada', 7458);
  INSERT INTO FACTURA VALUES (9459, 'F-2026-09459', TO_DATE('2026-04-08', 'YYYY-MM-DD'), TO_DATE('2026-05-08', 'YYYY-MM-DD'), 156.37, 171.37, 'Pagada', 7459);
  INSERT INTO FACTURA VALUES (9460, 'F-2026-09460', TO_DATE('2026-02-05', 'YYYY-MM-DD'), TO_DATE('2026-03-22', 'YYYY-MM-DD'), 176.09, 196.09, 'Emitida', 7460);
  INSERT INTO FACTURA VALUES (9461, 'F-2026-09461', TO_DATE('2026-04-13', 'YYYY-MM-DD'), TO_DATE('2026-05-28', 'YYYY-MM-DD'), 164.37, 184.37, 'Pagada', 7461);
  INSERT INTO FACTURA VALUES (9462, 'F-2026-09462', TO_DATE('2026-03-21', 'YYYY-MM-DD'), TO_DATE('2026-04-20', 'YYYY-MM-DD'), 166.78, 176.78, 'Pagada', 7462);
  INSERT INTO FACTURA VALUES (9463, 'F-2026-09463', TO_DATE('2026-01-07', 'YYYY-MM-DD'), TO_DATE('2026-02-21', 'YYYY-MM-DD'), 87.01, 107.01, 'Pagada', 7463);
  INSERT INTO FACTURA VALUES (9464, 'F-2026-09464', TO_DATE('2026-03-05', 'YYYY-MM-DD'), TO_DATE('2026-03-20', 'YYYY-MM-DD'), 60.49, 75.49, 'Pagada', 7464);
  INSERT INTO FACTURA VALUES (9465, 'F-2026-09465', TO_DATE('2026-01-25', 'YYYY-MM-DD'), TO_DATE('2026-03-11', 'YYYY-MM-DD'), 66.91, 86.91, 'Pagada', 7465);
  INSERT INTO FACTURA VALUES (9466, 'F-2026-09466', TO_DATE('2026-01-08', 'YYYY-MM-DD'), TO_DATE('2026-01-23', 'YYYY-MM-DD'), 211.56, 221.56, 'Anulada', 7466);
  INSERT INTO FACTURA VALUES (9467, 'F-2026-09467', TO_DATE('2026-03-11', 'YYYY-MM-DD'), TO_DATE('2026-04-25', 'YYYY-MM-DD'), 106.16, 121.16, 'Pagada', 7467);
  INSERT INTO FACTURA VALUES (9468, 'F-2026-09468', TO_DATE('2026-03-28', 'YYYY-MM-DD'), TO_DATE('2026-05-12', 'YYYY-MM-DD'), 152.62, 162.62, 'Pagada', 7468);
  INSERT INTO FACTURA VALUES (9469, 'F-2026-09469', TO_DATE('2026-04-11', 'YYYY-MM-DD'), TO_DATE('2026-04-26', 'YYYY-MM-DD'), 68.53, 83.53, 'Pagada', 7469);
  INSERT INTO FACTURA VALUES (9470, 'F-2026-09470', TO_DATE('2026-04-15', 'YYYY-MM-DD'), TO_DATE('2026-04-30', 'YYYY-MM-DD'), 40.26, 55.26, 'Pagada', 7470);
  INSERT INTO FACTURA VALUES (9471, 'F-2026-09471', TO_DATE('2026-03-31', 'YYYY-MM-DD'), TO_DATE('2026-05-15', 'YYYY-MM-DD'), 222.22, 242.22, 'Pagada', 7471);
  INSERT INTO FACTURA VALUES (9472, 'F-2026-09472', TO_DATE('2026-01-03', 'YYYY-MM-DD'), TO_DATE('2026-02-17', 'YYYY-MM-DD'), 158.25, 178.25, 'Pagada', 7472);
  INSERT INTO FACTURA VALUES (9473, 'F-2026-09473', TO_DATE('2026-02-01', 'YYYY-MM-DD'), TO_DATE('2026-02-16', 'YYYY-MM-DD'), 226.46, 246.46, 'Pagada', 7473);
  INSERT INTO FACTURA VALUES (9474, 'F-2026-09474', TO_DATE('2026-03-14', 'YYYY-MM-DD'), TO_DATE('2026-04-13', 'YYYY-MM-DD'), 80.38, 90.38, 'Anulada', 7474);
  INSERT INTO FACTURA VALUES (9475, 'F-2026-09475', TO_DATE('2026-01-05', 'YYYY-MM-DD'), TO_DATE('2026-01-20', 'YYYY-MM-DD'), 210.45, 220.45, 'Anulada', 7475);
  INSERT INTO FACTURA VALUES (9476, 'F-2026-09476', TO_DATE('2026-04-04', 'YYYY-MM-DD'), TO_DATE('2026-05-19', 'YYYY-MM-DD'), 207.94, 227.94, 'Pagada', 7476);
  INSERT INTO FACTURA VALUES (9477, 'F-2026-09477', TO_DATE('2026-03-20', 'YYYY-MM-DD'), TO_DATE('2026-05-04', 'YYYY-MM-DD'), 51.61, 66.61, 'Pagada', 7477);
  INSERT INTO FACTURA VALUES (9478, 'F-2026-09478', TO_DATE('2026-01-19', 'YYYY-MM-DD'), TO_DATE('2026-02-18', 'YYYY-MM-DD'), 179.21, 189.21, 'Anulada', 7478);
  INSERT INTO FACTURA VALUES (9479, 'F-2026-09479', TO_DATE('2026-03-30', 'YYYY-MM-DD'), TO_DATE('2026-04-14', 'YYYY-MM-DD'), 79.88, 99.88, 'Pagada', 7479);
  INSERT INTO FACTURA VALUES (9480, 'F-2026-09480', TO_DATE('2026-01-09', 'YYYY-MM-DD'), TO_DATE('2026-02-08', 'YYYY-MM-DD'), 130.55, 150.55, 'Pagada', 7480);
  INSERT INTO FACTURA VALUES (9481, 'F-2026-09481', TO_DATE('2026-02-11', 'YYYY-MM-DD'), TO_DATE('2026-02-26', 'YYYY-MM-DD'), 97.76, 112.76, 'Pagada', 7481);
  INSERT INTO FACTURA VALUES (9482, 'F-2026-09482', TO_DATE('2026-03-03', 'YYYY-MM-DD'), TO_DATE('2026-04-17', 'YYYY-MM-DD'), 138.49, 153.49, 'Pagada', 7482);
  INSERT INTO FACTURA VALUES (9483, 'F-2026-09483', TO_DATE('2026-04-27', 'YYYY-MM-DD'), TO_DATE('2026-05-12', 'YYYY-MM-DD'), 199.70, 214.70, 'Emitida', 7483);
  INSERT INTO FACTURA VALUES (9484, 'F-2026-09484', TO_DATE('2026-01-25', 'YYYY-MM-DD'), TO_DATE('2026-03-11', 'YYYY-MM-DD'), 104.89, 124.89, 'Anulada', 7484);
  INSERT INTO FACTURA VALUES (9485, 'F-2026-09485', TO_DATE('2026-02-02', 'YYYY-MM-DD'), TO_DATE('2026-02-17', 'YYYY-MM-DD'), 205.02, 225.02, 'Pagada', 7485);
  INSERT INTO FACTURA VALUES (9486, 'F-2026-09486', TO_DATE('2026-03-14', 'YYYY-MM-DD'), TO_DATE('2026-04-28', 'YYYY-MM-DD'), 221.78, 231.78, 'Emitida', 7486);
  INSERT INTO FACTURA VALUES (9487, 'F-2026-09487', TO_DATE('2026-04-27', 'YYYY-MM-DD'), TO_DATE('2026-05-27', 'YYYY-MM-DD'), 162.42, 177.42, 'Pagada', 7487);
  INSERT INTO FACTURA VALUES (9488, 'F-2026-09488', TO_DATE('2026-01-31', 'YYYY-MM-DD'), TO_DATE('2026-02-15', 'YYYY-MM-DD'), 49.08, 69.08, 'Emitida', 7488);
  INSERT INTO FACTURA VALUES (9489, 'F-2026-09489', TO_DATE('2026-02-18', 'YYYY-MM-DD'), TO_DATE('2026-04-04', 'YYYY-MM-DD'), 209.99, 219.99, 'Emitida', 7489);
  INSERT INTO FACTURA VALUES (9490, 'F-2026-09490', TO_DATE('2026-04-22', 'YYYY-MM-DD'), TO_DATE('2026-06-06', 'YYYY-MM-DD'), 189.70, 199.70, 'Pagada', 7490);
  INSERT INTO FACTURA VALUES (9491, 'F-2026-09491', TO_DATE('2026-02-06', 'YYYY-MM-DD'), TO_DATE('2026-02-21', 'YYYY-MM-DD'), 201.80, 216.80, 'Anulada', 7491);
  INSERT INTO FACTURA VALUES (9492, 'F-2026-09492', TO_DATE('2026-04-07', 'YYYY-MM-DD'), TO_DATE('2026-05-22', 'YYYY-MM-DD'), 109.31, 129.31, 'Pagada', 7492);
  INSERT INTO FACTURA VALUES (9493, 'F-2026-09493', TO_DATE('2026-03-10', 'YYYY-MM-DD'), TO_DATE('2026-04-24', 'YYYY-MM-DD'), 115.28, 125.28, 'Emitida', 7493);
  INSERT INTO FACTURA VALUES (9494, 'F-2026-09494', TO_DATE('2026-04-08', 'YYYY-MM-DD'), TO_DATE('2026-05-08', 'YYYY-MM-DD'), 177.16, 192.16, 'Anulada', 7494);
  INSERT INTO FACTURA VALUES (9495, 'F-2026-09495', TO_DATE('2026-01-17', 'YYYY-MM-DD'), TO_DATE('2026-03-03', 'YYYY-MM-DD'), 153.99, 163.99, 'Emitida', 7495);
  INSERT INTO FACTURA VALUES (9496, 'F-2026-09496', TO_DATE('2026-01-04', 'YYYY-MM-DD'), TO_DATE('2026-01-19', 'YYYY-MM-DD'), 175.39, 185.39, 'Pagada', 7496);
  INSERT INTO FACTURA VALUES (9497, 'F-2026-09497', TO_DATE('2026-02-22', 'YYYY-MM-DD'), TO_DATE('2026-04-08', 'YYYY-MM-DD'), 49.38, 59.38, 'Pagada', 7497);
  INSERT INTO FACTURA VALUES (9498, 'F-2026-09498', TO_DATE('2026-02-28', 'YYYY-MM-DD'), TO_DATE('2026-03-30', 'YYYY-MM-DD'), 126.51, 141.51, 'Pagada', 7498);
  INSERT INTO FACTURA VALUES (9499, 'F-2026-09499', TO_DATE('2026-03-14', 'YYYY-MM-DD'), TO_DATE('2026-04-28', 'YYYY-MM-DD'), 72.99, 92.99, 'Pagada', 7499);
  INSERT INTO FACTURA VALUES (9500, 'F-2026-09500', TO_DATE('2026-03-23', 'YYYY-MM-DD'), TO_DATE('2026-04-22', 'YYYY-MM-DD'), 84.69, 94.69, 'Pagada', 7500);
  COMMIT;
END;