# SQL-instances_documentation

Este proyecto tiene como objetivo facilitar una auditoría completa de todos los objetos existentes en una instancia de SQL Server. Permite realizar búsquedas dentro de una tabla centralizada que contiene información detallada de dichos objetos. Observe el lector que el existen dos procedimientos, uno es metadatos que reune en si todos los objetos de la instancia para su documentación y por otro lado está Metadatoscampos, que se centra solo en las tablas y vistas, recogiendo también sus columnas para una fotografía completa de la instancia. Es claro, que para que estos procedimientos mantengan la tabla actualizada se podría ocupar un job que de forma periódica ejecute los procedimientos, por ejemplo, semanalmente. 

## Descripción

El sistema se basa en un procedimiento de actualización que consta de tres partes:

- Procedimiento para registrar **objetos eliminados**
- Procedimiento para registrar **objetos nuevos**
- Procedimiento para detectar y registrar **objetos coincidentes**

Estos procedimientos trabajan de forma conjunta para mantener actualizada una **tabla física** que actúa como repositorio de toda la información estructural de la instancia.

## Uso previsto

Este repositorio está diseñado para su uso en entornos de desarrollo, documentación interna o auditoría técnica de instancias SQL Server.

---

## ⚠️ Licencia y restricciones de uso

Este repositorio está licenciado bajo la Creative Commons Atribución-No Comercial 4.0 Internacional (CC BY-NC 4.0).
Puedes encontrar los detalles completos de la licencia [aquí](https://creativecommons.org/licenses/by-nc/4.0/).

Atribución: Cita a los autores originales.

No Comercial: No puedes usar el código para fines comerciales.
