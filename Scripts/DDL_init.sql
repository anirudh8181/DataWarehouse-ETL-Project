/*
=============================================================
Create Databases
=============================================================

Script Purpose:
    This script creates three databases representing the
    Bronze, Silver, and Gold layers of a data warehouse.

WARNING:
    Running this script will drop the existing databases
    if they exist. All data will be permanently deleted.
    Proceed with caution.
*/


CREATE DATABASE DataWareHouse;

USE DataWareHouse;

-- =========================================================
-- Drop existing databases
-- =========================================================

DROP DATABASE IF EXISTS Bronze;
DROP DATABASE IF EXISTS Silver;
DROP DATABASE IF EXISTS Gold;


-- =========================================================
-- Create Bronze, Silver and Gold databases
-- =========================================================

CREATE DATABASE Bronze;

CREATE DATABASE Silver;

CREATE DATABASE Gold;