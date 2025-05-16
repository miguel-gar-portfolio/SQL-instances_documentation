# SQL-instances_documentation

Este proyecto tiene como objetivo facilitar una auditoría completa de todos los objetos existentes en una instancia de SQL Server. Permite realizar búsquedas dentro de una tabla centralizada que contiene información detallada de dichos objetos.

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

Este proyecto se distribuye **únicamente para fines no comerciales**.  
**Queda prohibido su uso con fines comerciales**, total o parcialmente, sin autorización previa y expresa del autor.

Si deseas utilizar este proyecto en un contexto comercial, por favor contáctame para obtener los permisos correspondientes.

---
