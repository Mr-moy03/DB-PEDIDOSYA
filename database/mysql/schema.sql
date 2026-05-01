-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: pedidosya
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `cliente`
--

DROP TABLE IF EXISTS `cliente`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cliente` (
  `id_persona` int NOT NULL,
  `puntos_fidelidad` int DEFAULT '0',
  `fecha_registro` date DEFAULT (curdate()),
  `estado_cliente` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Activo',
  PRIMARY KEY (`id_persona`),
  CONSTRAINT `fk_cliente_persona` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE,
  CONSTRAINT `cliente_chk_1` CHECK ((`puntos_fidelidad` >= 0)),
  CONSTRAINT `cliente_chk_2` CHECK ((`estado_cliente` in (_utf8mb4'Activo',_utf8mb4'Inactivo',_utf8mb4'Suspendido')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `contiene`
--

DROP TABLE IF EXISTS `contiene`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contiene` (
  `id_pedido` int NOT NULL,
  `id_producto` int NOT NULL,
  `id_sucursal` int NOT NULL,
  `cantidad` int NOT NULL,
  PRIMARY KEY (`id_pedido`,`id_producto`,`id_sucursal`),
  KEY `fk_contiene_producto` (`id_producto`),
  KEY `fk_contiene_sucursal` (`id_sucursal`),
  CONSTRAINT `fk_contiene_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`id_pedido`) ON DELETE CASCADE,
  CONSTRAINT `fk_contiene_producto` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`),
  CONSTRAINT `fk_contiene_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`),
  CONSTRAINT `contiene_chk_1` CHECK ((`cantidad` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `direccion`
--

DROP TABLE IF EXISTS `direccion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `direccion` (
  `id_direccion` int NOT NULL,
  `zona_cli` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `calle_cli` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `numero_puerta` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `id_cliente` int NOT NULL,
  PRIMARY KEY (`id_direccion`),
  KEY `fk_direccion_cliente` (`id_cliente`),
  CONSTRAINT `fk_direccion_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_persona`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `empresa_delivery`
--

DROP TABLE IF EXISTS `empresa_delivery`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `empresa_delivery` (
  `id_empresa` int NOT NULL,
  `razon_social` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nit_empresa` varchar(25) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono_central` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tarifa_base` decimal(10,2) NOT NULL,
  `costo_por_km` decimal(8,2) NOT NULL,
  `estado_empresa` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Activo',
  PRIMARY KEY (`id_empresa`),
  UNIQUE KEY `nit_empresa` (`nit_empresa`),
  CONSTRAINT `empresa_delivery_chk_1` CHECK ((`tarifa_base` >= 0)),
  CONSTRAINT `empresa_delivery_chk_2` CHECK ((`costo_por_km` >= 0)),
  CONSTRAINT `empresa_delivery_chk_3` CHECK ((`estado_empresa` in (_utf8mb4'Activo',_utf8mb4'Inactivo',_utf8mb4'Suspendido')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `factura`
--

DROP TABLE IF EXISTS `factura`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `factura` (
  `id_factura` int NOT NULL,
  `numero_factura` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_emision` date DEFAULT (curdate()),
  `fecha_vencimiento` date DEFAULT NULL,
  `subtotal` decimal(12,2) NOT NULL,
  `total_factura` decimal(12,2) NOT NULL,
  `estado_factura` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Emitida',
  `id_pedido` int NOT NULL,
  PRIMARY KEY (`id_factura`),
  UNIQUE KEY `numero_factura` (`numero_factura`),
  UNIQUE KEY `id_pedido` (`id_pedido`),
  CONSTRAINT `fk_factura_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`id_pedido`) ON DELETE CASCADE,
  CONSTRAINT `factura_chk_1` CHECK ((`subtotal` >= 0)),
  CONSTRAINT `factura_chk_2` CHECK ((`total_factura` >= 0)),
  CONSTRAINT `factura_chk_3` CHECK ((`estado_factura` in (_utf8mb4'Emitida',_utf8mb4'Pagada',_utf8mb4'Anulada',_utf8mb4'Vencida')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `negocio`
--

DROP TABLE IF EXISTS `negocio`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `negocio` (
  `id_negocio` int NOT NULL,
  `nombre_negocio` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo_negocio` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hora_apertura` varchar(5) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hora_cierre` varchar(5) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dias_atencion` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_negocio` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Activo',
  PRIMARY KEY (`id_negocio`),
  CONSTRAINT `negocio_chk_1` CHECK ((`estado_negocio` in (_utf8mb4'Activo',_utf8mb4'Inactivo',_utf8mb4'Cerrado')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `ofrece`
--

DROP TABLE IF EXISTS `ofrece`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ofrece` (
  `id_sucursal` int NOT NULL,
  `id_producto` int NOT NULL,
  PRIMARY KEY (`id_sucursal`,`id_producto`),
  KEY `fk_ofrece_producto` (`id_producto`),
  CONSTRAINT `fk_ofrece_producto` FOREIGN KEY (`id_producto`) REFERENCES `producto` (`id_producto`) ON DELETE CASCADE,
  CONSTRAINT `fk_ofrece_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pago`
--

DROP TABLE IF EXISTS `pago`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pago` (
  `id_pago` int NOT NULL,
  `tipo_pago` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL,
  `monto` decimal(12,2) NOT NULL,
  `estado_pago` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Pendiente',
  `fecha_pago` date DEFAULT (curdate()),
  `id_pedido` int NOT NULL,
  PRIMARY KEY (`id_pago`),
  KEY `fk_pago_pedido` (`id_pedido`),
  CONSTRAINT `fk_pago_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`id_pedido`) ON DELETE CASCADE,
  CONSTRAINT `pago_chk_1` CHECK ((`tipo_pago` in (_utf8mb4'Efectivo',_utf8mb4'Tarjeta',_utf8mb4'QR',_utf8mb4'Transferencia',_utf8mb4'App'))),
  CONSTRAINT `pago_chk_2` CHECK ((`monto` > 0)),
  CONSTRAINT `pago_chk_3` CHECK ((`estado_pago` in (_utf8mb4'Pendiente',_utf8mb4'Pagado',_utf8mb4'Rechazado',_utf8mb4'Reembolsado')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pedido`
--

DROP TABLE IF EXISTS `pedido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedido` (
  `id_pedido` int NOT NULL,
  `fecha_solicitud` date DEFAULT (curdate()),
  `hora_solicitud` varchar(5) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_pedido` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT 'Pendiente',
  `total_productos` decimal(12,2) DEFAULT '0.00',
  `costo_envio` decimal(10,2) DEFAULT '0.00',
  `total_final` decimal(12,2) DEFAULT '0.00',
  `id_cliente` int NOT NULL,
  `id_direccion` int NOT NULL,
  `id_repartidor` int DEFAULT NULL,
  PRIMARY KEY (`id_pedido`),
  KEY `fk_pedido_cliente` (`id_cliente`),
  KEY `fk_pedido_direccion` (`id_direccion`),
  KEY `fk_pedido_repartidor` (`id_repartidor`),
  CONSTRAINT `fk_pedido_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `cliente` (`id_persona`),
  CONSTRAINT `fk_pedido_direccion` FOREIGN KEY (`id_direccion`) REFERENCES `direccion` (`id_direccion`),
  CONSTRAINT `fk_pedido_repartidor` FOREIGN KEY (`id_repartidor`) REFERENCES `repartidor` (`id_persona`),
  CONSTRAINT `pedido_chk_1` CHECK ((`estado_pedido` in (_utf8mb4'Pendiente',_utf8mb4'Confirmado',_utf8mb4'En preparacion',_utf8mb4'Listo para entregar',_utf8mb4'En camino',_utf8mb4'Entregado',_utf8mb4'Cancelado'))),
  CONSTRAINT `pedido_chk_2` CHECK ((`total_productos` >= 0)),
  CONSTRAINT `pedido_chk_3` CHECK ((`costo_envio` >= 0)),
  CONSTRAINT `pedido_chk_4` CHECK ((`total_final` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `persona`
--

DROP TABLE IF EXISTS `persona`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `persona` (
  `id_persona` int NOT NULL,
  `nombre_per` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido_paterno` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellido_materno` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_nac` date DEFAULT NULL,
  `ci_documento` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono_per` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correo_per` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `edad` int DEFAULT NULL,
  PRIMARY KEY (`id_persona`),
  UNIQUE KEY `ci_documento` (`ci_documento`),
  UNIQUE KEY `correo_per` (`correo_per`),
  CONSTRAINT `persona_chk_1` CHECK (((`edad` >= 0) and (`edad` <= 120)))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `producto`
--

DROP TABLE IF EXISTS `producto`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `producto` (
  `id_producto` int NOT NULL,
  `nombre_producto` varchar(150) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion_producto` text COLLATE utf8mb4_unicode_ci,
  `precio_unitario` decimal(10,2) NOT NULL,
  `estado_producto` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Activo',
  PRIMARY KEY (`id_producto`),
  CONSTRAINT `producto_chk_1` CHECK ((`precio_unitario` > 0)),
  CONSTRAINT `producto_chk_2` CHECK ((`estado_producto` in (_utf8mb4'Activo',_utf8mb4'Inactivo',_utf8mb4'Agotado')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `promocion`
--

DROP TABLE IF EXISTS `promocion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `promocion` (
  `id_promocion` int NOT NULL,
  `descripcion_promocion` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tipo_promocion` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `porcentaje_descuento` decimal(5,2) DEFAULT NULL,
  `estado_promo` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Activa',
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `id_sucursal` int NOT NULL,
  PRIMARY KEY (`id_promocion`),
  KEY `fk_promocion_sucursal` (`id_sucursal`),
  CONSTRAINT `fk_promocion_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`) ON DELETE CASCADE,
  CONSTRAINT `promocion_chk_1` CHECK ((`porcentaje_descuento` between 0 and 100)),
  CONSTRAINT `promocion_chk_2` CHECK ((`estado_promo` in (_utf8mb4'Activa',_utf8mb4'Inactiva',_utf8mb4'Vencida'))),
  CONSTRAINT `promocion_chk_3` CHECK ((`fecha_fin` >= `fecha_inicio`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `recibe`
--

DROP TABLE IF EXISTS `recibe`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `recibe` (
  `id_pedido` int NOT NULL,
  `id_sucursal` int NOT NULL,
  PRIMARY KEY (`id_pedido`,`id_sucursal`),
  KEY `fk_recibe_sucursal` (`id_sucursal`),
  CONSTRAINT `fk_recibe_pedido` FOREIGN KEY (`id_pedido`) REFERENCES `pedido` (`id_pedido`) ON DELETE CASCADE,
  CONSTRAINT `fk_recibe_sucursal` FOREIGN KEY (`id_sucursal`) REFERENCES `sucursal` (`id_sucursal`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `repartidor`
--

DROP TABLE IF EXISTS `repartidor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `repartidor` (
  `id_persona` int NOT NULL,
  `nro_licencia` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `estado_disponibilidad` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT 'Disponible',
  `medio_transporte` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `salario` decimal(10,2) DEFAULT NULL,
  `id_empresa` int NOT NULL,
  PRIMARY KEY (`id_persona`),
  UNIQUE KEY `nro_licencia` (`nro_licencia`),
  KEY `fk_repartidor_empresa` (`id_empresa`),
  CONSTRAINT `fk_repartidor_empresa` FOREIGN KEY (`id_empresa`) REFERENCES `empresa_delivery` (`id_empresa`),
  CONSTRAINT `fk_repartidor_persona` FOREIGN KEY (`id_persona`) REFERENCES `persona` (`id_persona`) ON DELETE CASCADE,
  CONSTRAINT `repartidor_chk_1` CHECK ((`estado_disponibilidad` in (_utf8mb4'Disponible',_utf8mb4'Ocupado',_utf8mb4'Fuera de servicio'))),
  CONSTRAINT `repartidor_chk_2` CHECK ((`salario` >= 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `se_asocia`
--

DROP TABLE IF EXISTS `se_asocia`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `se_asocia` (
  `id_empresa` int NOT NULL,
  `id_negocio` int NOT NULL,
  PRIMARY KEY (`id_empresa`,`id_negocio`),
  KEY `fk_asocia_negocio` (`id_negocio`),
  CONSTRAINT `fk_asocia_empresa` FOREIGN KEY (`id_empresa`) REFERENCES `empresa_delivery` (`id_empresa`) ON DELETE CASCADE,
  CONSTRAINT `fk_asocia_negocio` FOREIGN KEY (`id_negocio`) REFERENCES `negocio` (`id_negocio`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `sucursal`
--

DROP TABLE IF EXISTS `sucursal`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sucursal` (
  `id_sucursal` int NOT NULL,
  `nombre_sucursal` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `zona_suc` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `calle_suc` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_negocio` int NOT NULL,
  PRIMARY KEY (`id_sucursal`),
  KEY `fk_sucursal_negocio` (`id_negocio`),
  CONSTRAINT `fk_sucursal_negocio` FOREIGN KEY (`id_negocio`) REFERENCES `negocio` (`id_negocio`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-05-01 17:43:34
