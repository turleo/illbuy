CREATE SCHEMA IF NOT EXISTS xid;

CREATE SEQUENCE IF NOT EXISTS xid.serial MINVALUE 0 MAXVALUE 256 CYCLE;

CREATE OR REPLACE FUNCTION xid.machine_id()
    RETURNS SMALLINT
    LANGUAGE plpgsql
    IMMUTABLE
AS $$
BEGIN
    RETURN (SELECT system_identifier % 256 FROM pg_control_system());
END;
$$;

CREATE OR REPLACE FUNCTION xid.time()
    RETURNS INT
    LANGUAGE plpgsql
    IMMUTABLE
AS $$
BEGIN
    RETURN round(EXTRACT(epoch FROM age(now(), TIMESTAMP '2025-01-01 0:0:0+0')));
END;
$$;

CREATE OR REPLACE FUNCTION xid.generate(pid int)
    RETURNS BIGINT
    LANGUAGE plpgsql
    VOLATILE
AS $$
BEGIN
    RETURN (
        (xid.time() << (4 * 8)) +
        (xid.machine_id() << (3 * 8)) +
        (pid << 8) +
        nextval('xid.serial')
    );
END;
$$;

COMMENT ON SCHEMA xid IS 'ID generator';

