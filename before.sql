DROP TABLE IF EXISTS net_combined;
CREATE TABLE net_combined (
    s inet, -- start point
    e inet, -- end point
    t1 text,-- text 1
    t2 text -- text 2
);

DROP TABLE IF EXISTS net_endpoints;
CREATE TABLE net_endpoints (
    p inet,     -- endpoint
    s boolean,  -- is start
    t1 text,    -- text 1
    t2 text     -- text 2
);

DROP TABLE IF EXISTS net_flat;
CREATE TABLE net_flat (
    s inet, -- start point
    e inet, -- end point
    t1 text,-- text 1
    t2 text -- text 2
);

-- function to fill net_endpoints with net_combined data
CREATE OR REPLACE FUNCTION p() RETURNS VOID AS $$
DECLARE
    rec RECORD;
BEGIN
    -- since there are several records with equal start and end points, select only
    -- the first record
    FOR rec IN SELECT DISTINCT ON (s, e) * FROM net_combined WHERE e > '0.0.0.0' ORDER BY s LOOP
        INSERT INTO net_endpoints(p, s, t1, t2) VALUES (rec.s, TRUE, rec.t1, rec.t2);
        INSERT INTO net_endpoints(p, s, t1, t2) VALUES (rec.e, FALSE, rec.t1, rec.t2);
    END LOOP;
END
$$ LANGUAGE plpgsql;


-- flatten function
CREATE OR REPLACE FUNCTION f()
RETURNS TABLE(s inet, e inet, t1 text, t2 text) AS $$
DECLARE
    rec RECORD;
    last_start inet DEFAULT NULL;
    current_t text[];
    t text[2];
BEGIN
    FOR rec IN SELECT DISTINCT ON (p, s) * FROM net_endpoints ORDER BY p LOOP
        IF rec.s THEN
            IF last_start IS NOT NULL THEN
                t = regexp_split_to_array(
                    current_t[array_upper(current_t, 1)],
                    '@@DIVIDER@@'
                );
                INSERT INTO net_flat(s, e, t1, t2)
                VALUES (last_start, rec.p-1, t[1], t[2]);
            END IF;
                current_t = array_append(
                    current_t, rec.t1 || '@@DIVIDER@@' || rec.t2
                );
                last_start = rec.p;
        ELSE
            t = regexp_split_to_array(
                current_t[array_upper(current_t, 1)],
                '@@DIVIDER@@'
            );
            INSERT INTO net_flat(s, e, t1, t2)
            VALUES (last_start, rec.p, t[1], t[2]);
            current_t =
                current_t[array_lower(current_t,1) : array_upper(current_t,1)-1];
            IF rec.p = '255.255.255.255' THEN
                last_start = rec.p;
            ELSE
                last_start = rec.p+1;
            END IF;
        END IF;
    END LOOP;
    RETURN QUERY SELECT * FROM net_flat ORDER BY s;
END
$$ LANGUAGE plpgsql;
