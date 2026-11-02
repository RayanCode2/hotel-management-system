--
-- PostgreSQL database dump
--

\restrict FDP2H2XRoHaa6dRpoqjH48DSrBZcY96hSj04gqH0aURjsWZdcHmdVOco4FaTWEf

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2026-04-10 16:05:30 EDT

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 232 (class 1255 OID 34622)
-- Name: archive_deleted_reservation(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.archive_deleted_reservation() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    INSERT INTO reservation_archive (reservation_id, customer_sin, hotel_room_id, status, start_date, end_date)
    VALUES (OLD.reservation_id, OLD.customer_sin, OLD.hotel_room_id, OLD.status, OLD.start_date, OLD.end_date);
    RETURN OLD;
END;$$;


ALTER FUNCTION public.archive_deleted_reservation() OWNER TO postgres;

--
-- TOC entry 231 (class 1255 OID 34616)
-- Name: check_reservation_dates(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.check_reservation_dates() RETURNS trigger
    LANGUAGE plpgsql
    AS $$BEGIN
    IF NEW.end_date <= NEW.start_date THEN
        RAISE EXCEPTION 'Erreur : La date de fin doit être après la date de début.';
    END IF;
    RETURN NEW;
END;$$;


ALTER FUNCTION public.check_reservation_dates() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 227 (class 1259 OID 34722)
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    customer_id integer NOT NULL,
    full_name character varying(100) NOT NULL,
    address text,
    id_type character varying(50)
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 34721)
-- Name: customer_customer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customer_customer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_customer_id_seq OWNER TO postgres;

--
-- TOC entry 3905 (class 0 OID 0)
-- Dependencies: 226
-- Name: customer_customer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customer_customer_id_seq OWNED BY public.customer.customer_id;


--
-- TOC entry 223 (class 1259 OID 34566)
-- Name: employee; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employee (
    employee_id integer NOT NULL,
    social_insurance_number integer,
    role character varying(15),
    hotel_number integer,
    full_name character varying(100),
    address text
);


ALTER TABLE public.employee OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 34536)
-- Name: hotel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hotel (
    hotel_number integer NOT NULL,
    name character varying(50),
    chain_number integer,
    street_number integer,
    street_name character varying(50),
    city character varying(50),
    state character varying(50),
    zip_code character varying(6),
    email character varying(50),
    phone character(10),
    manager_id integer,
    rating integer,
    chain_name character varying(50)
);


ALTER TABLE public.hotel OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 34530)
-- Name: hotel_chain; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hotel_chain (
    chain_number integer NOT NULL,
    name character varying(50),
    street_number integer,
    street_name character varying(50),
    city character varying(50),
    state character varying(50),
    zip_code character varying(6),
    email character varying(50),
    phone character(10)
);


ALTER TABLE public.hotel_chain OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 34547)
-- Name: hotel_room; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.hotel_room (
    hotel_room_id integer NOT NULL,
    room_number integer,
    hotel_number integer,
    price numeric,
    capacity integer,
    amenities character varying(255),
    view character varying(255),
    extendable boolean,
    known_issues character varying(255),
    superficie integer
);


ALTER TABLE public.hotel_room OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 34733)
-- Name: reservation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservation (
    reservation_id integer NOT NULL,
    room_number character varying(20) NOT NULL,
    start_date date DEFAULT CURRENT_DATE NOT NULL,
    end_date date DEFAULT (CURRENT_DATE + '1 day'::interval) NOT NULL,
    customer_id integer NOT NULL,
    statut character varying(20) DEFAULT 'EN ATTENTE'::character varying,
    checkin_employee_id integer,
    hotel_number integer,
    CONSTRAINT check_dates CHECK ((end_date > start_date))
);


ALTER TABLE public.reservation OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 34618)
-- Name: reservation_archive; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservation_archive (
    reservation_id integer,
    customer_sin integer,
    hotel_room_id integer,
    status character varying(15),
    start_date date,
    end_date date,
    deleted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.reservation_archive OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 34732)
-- Name: reservation_reservation_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.reservation_reservation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.reservation_reservation_id_seq OWNER TO postgres;

--
-- TOC entry 3906 (class 0 OID 0)
-- Dependencies: 228
-- Name: reservation_reservation_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.reservation_reservation_id_seq OWNED BY public.reservation.reservation_id;


--
-- TOC entry 222 (class 1259 OID 34560)
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    social_insurance_number integer NOT NULL,
    first_name character varying(50),
    middle_name character varying(50),
    last_name character varying(50),
    street_number integer,
    street_name character varying(50),
    apt_number integer,
    city character varying(50),
    state character varying(50),
    zip_code character varying(6),
    email character varying(50),
    phone_number character(10),
    creation_date date
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 34608)
-- Name: vue_capacite_totale_hotel; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vue_capacite_totale_hotel AS
 SELECT h.name AS nom_hotel,
    sum(r.capacity) AS capacite_totale
   FROM (public.hotel h
     JOIN public.hotel_room r ON ((h.hotel_number = r.hotel_number)))
  GROUP BY h.hotel_number, h.name;


ALTER VIEW public.vue_capacite_totale_hotel OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 34788)
-- Name: vue_chambres_dispo_par_zone; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vue_chambres_dispo_par_zone AS
 SELECT h.city AS zone,
    count(hr.room_number) AS nombre_chambres_disponibles
   FROM (public.hotel h
     JOIN public.hotel_room hr ON ((h.hotel_number = hr.hotel_number)))
  WHERE (NOT (((hr.room_number)::character varying)::text IN ( SELECT (res.room_number)::character varying AS room_number
           FROM public.reservation res
          WHERE ((res.hotel_number = h.hotel_number) AND ((res.statut)::text = 'OCCUPÉ'::text)))))
  GROUP BY h.city;


ALTER VIEW public.vue_chambres_dispo_par_zone OWNER TO postgres;

--
-- TOC entry 3710 (class 2604 OID 34725)
-- Name: customer customer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer ALTER COLUMN customer_id SET DEFAULT nextval('public.customer_customer_id_seq'::regclass);


--
-- TOC entry 3711 (class 2604 OID 34736)
-- Name: reservation reservation_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation ALTER COLUMN reservation_id SET DEFAULT nextval('public.reservation_reservation_id_seq'::regclass);


--
-- TOC entry 3897 (class 0 OID 34722)
-- Dependencies: 227
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer (customer_id, full_name, address, id_type) FROM stdin;
\.


--
-- TOC entry 3894 (class 0 OID 34566)
-- Dependencies: 223
-- Data for Name: employee; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employee (employee_id, social_insurance_number, role, hotel_number, full_name, address) FROM stdin;
1	1001	Gérant	1	Claude Bédard	10 Rue des Carrières, Québec
2	1002	Réceptionniste	1	Diane Lapointe	20 Rue St-Jean, Québec
3	1003	Réceptionniste	1	Mario Proulx	30 Blvd Champlain, Québec
4	1004	Concierge	1	Line Caron	40 Rue Petit-Champlain, Québec
5	1005	Entretien	1	Guy Richard	50 Ave Honoré-Mercier, Québec
6	1006	Entretien	1	France Nadeau	60 Chemin Ste-Foy, Québec
7	1007	Valet	1	Denis Girard	70 Blvd Laurier, Québec
8	2001	Gérant	2	Alain Côté	100 Rue Ste-Catherine, Montréal
9	2002	Réceptionniste	2	Céline Lavoie	200 Blvd René-Lévesque, Montréal
10	2003	Réceptionniste	2	Michel Pelletier	300 Rue Peel, Montréal
11	2004	Concierge	2	Louise Bouchard	400 Ave Mont-Royal, Montréal
12	2005	Entretien	2	Pierre Simard	500 Rue St-Denis, Montréal
13	2006	Entretien	2	Sylvie Martel	600 Blvd St-Laurent, Montréal
14	2007	Valet	2	Jacques Ouellet	700 Ave Parc, Montréal
15	3001	Gérant	3	Julie Tremblay	10 Rue de la Gauchetière, Montréal
16	3002	Réceptionniste	3	Marc Leblanc	20 Rue St-Antoine, Montréal
17	3003	Réceptionniste	3	Sophie Gagnon	30 Rue McGill, Montréal
18	3004	Concierge	3	Luc Fortin	40 Rue Wellington, Montréal
19	3005	Entretien	3	Marie Morin	50 Rue Notre-Dame, Montréal
20	3006	Entretien	3	Paul Roy	60 Rue St-Jacques, Montréal
21	3007	Valet	3	Isabelle Gauthier	70 Rue Sherbrooke, Montréal
22	4001	Gérant	4	John Smith	10 Wellington St, Toronto
23	4002	Réceptionniste	4	Emma Johnson	20 Bay St, Toronto
24	4003	Réceptionniste	4	Michael Brown	30 King St, Toronto
25	4004	Concierge	4	Sarah Williams	40 Queen St, Toronto
26	4005	Entretien	4	David Jones	50 Bloor St, Toronto
27	4006	Entretien	4	Lisa Garcia	60 Dundas St, Toronto
28	4007	Valet	4	James Miller	70 College St, Toronto
29	5001	Gérant	5	Kevin Martin	10 Burrard St, Vancouver
30	5002	Réceptionniste	5	Nancy Thompson	20 Robson St, Vancouver
31	5003	Réceptionniste	5	Brian Moore	30 Granville St, Vancouver
32	5004	Concierge	5	Karen Clark	40 Hastings St, Vancouver
33	5005	Entretien	5	George Walker	50 Georgia St, Vancouver
34	5006	Entretien	5	Betty Hall	60 Seymour St, Vancouver
35	5007	Valet	5	Edward Allen	70 Howe St, Vancouver
36	6001	Gérant	6	Robert Wilson	10 Spray Ave, Banff
37	6002	Réceptionniste	6	Mary Taylor	20 Bear St, Banff
38	6003	Réceptionniste	6	William Davies	30 Caribou St, Banff
39	6004	Concierge	6	Linda Evans	40 Wolf St, Banff
40	6005	Entretien	6	Richard Thomas	50 Lynx St, Banff
41	6006	Entretien	6	Susan White	60 Elk St, Banff
42	6007	Valet	6	Charles Harris	70 Moose St, Banff
43	7001	Gérant	7	Jean Tremblay	10 Rue Kent, Ottawa
44	7002	Réceptionniste	7	Marie Gauthier	20 Rue Bank, Ottawa
45	7003	Réceptionniste	7	Paul Leblanc	30 Rue Elgin, Ottawa
46	7004	Concierge	7	Sophie Roy	40 Rue Sparks, Ottawa
47	7005	Entretien	7	Luc Morin	50 Prom. Sussex, Ottawa
48	7006	Entretien	7	Julie Fortin	60 Rue Metcalfe, Ottawa
49	7007	Valet	7	Marc Gagnon	70 Rue Rideau, Ottawa
50	8001	Gérant	8	Martin Blais	10 Rue Slater, Ottawa
51	8002	Réceptionniste	8	Nathalie Leduc	20 Rue Albert, Ottawa
52	8003	Réceptionniste	8	Simon Paquette	30 Rue O'Connor, Ottawa
53	8004	Concierge	8	Chantal Renaud	40 Rue Laurier, Ottawa
54	8005	Entretien	8	Vincent Dugas	50 Rue Somerset, Ottawa
55	8006	Entretien	8	Valérie Côté	60 Rue Gladstone, Ottawa
56	8007	Valet	8	Alexandre Houle	70 Rue Bronson, Ottawa
\.


--
-- TOC entry 3891 (class 0 OID 34536)
-- Dependencies: 220
-- Data for Name: hotel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hotel (hotel_number, name, chain_number, street_number, street_name, city, state, zip_code, email, phone, manager_id, rating, chain_name) FROM stdin;
1	Fairmont Le Château Frontenac	1	10	Rue Saint-Jean	Quebec	QC	G1R1N7	quebec@chain1.com	4185550001	1	5	Fairmont
6	Fairmont Banff Springs	1	100	Banff Ave	Banff	AB	T1L1A1	banff@chain1.com	4035550002	2	5	Fairmont
7	Ottawa Marriott Hotel	1	50	Rideau St	Ottawa	ON	K1N5W8	ottawa1@chain1.com	6135550003	3	4	Marriott
2	Le Westin Montréal	1	1200	Rue Peel	Montreal	QC	H3B2T6	mtl1@chain1.com	5145550004	4	4	Starwood
5	Sheraton Vancouver Wall Centre	2	900	Canada Pl	Vancouver	BC	V6C3L5	van@chain2.com	6045550005	5	4	Starwood
8	Alt Hotel Ottawa	2	100	Elgin St	Ottawa	ON	K1P5K8	ottawa2@chain2.com	6135550006	6	3	Groupe Germain
3	Hotel Bonaventure	2	1000	De La Gauchetiere	Montreal	QC	H3B4W5	mtl2@chain2.com	5145550007	7	4	Indépendant
4	The Ritz-Carlton	2	100	Front St W	Toronto	ON	M5J1E3	toronto@chain2.com	4165550008	8	5	Ritz-Carlton
\.


--
-- TOC entry 3890 (class 0 OID 34530)
-- Dependencies: 219
-- Data for Name: hotel_chain; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hotel_chain (chain_number, name, street_number, street_name, city, state, zip_code, email, phone) FROM stdin;
1	LuxeStays	10	Rue de la Paix	Montreal	QC	H3Z2Y7	contact@luxestays.ca	5141112222
2	BudgetSleep	20	Queen Street	Toronto	ON	M5H2M5	info@budgetsleep.ca	4163334444
3	OceanView	30	Waterfront	Vancouver	BC	V6C2T4	hello@oceanview.ca	6045556666
4	CityCenter Inn	40	Rideau Street	Ottawa	ON	K1N5Y4	admin@citycenter.ca	6137778888
5	NatureRetreat	50	Banff Ave	Banff	AB	T1L1A1	booking@nature.ca	4039990000
\.


--
-- TOC entry 3892 (class 0 OID 34547)
-- Dependencies: 221
-- Data for Name: hotel_room; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.hotel_room (hotel_room_id, room_number, hotel_number, price, capacity, amenities, view, extendable, known_issues, superficie) FROM stdin;
1	101	1	150.00	2	Wi-Fi, TV, Climatisation	Vue Château	f	Petite égratignure sur le mur	40
6	301	1	350.00	4	Wi-Fi, TV, Climatisation	Luxe Royale	t	Fenêtre difficile à fermer	70
3	103	1	250.00	4	Wi-Fi, TV, Climatisation	Suite Famille	t	Aucun problème	70
10	501	1	500.00	4	Wi-Fi, TV, Climatisation	Penthouse	t	Aucun problème	70
13	103	2	310.00	4	Wi-Fi, TV, Climatisation	Suite Affaires	t	Aucun problème	70
16	301	2	400.00	4	Wi-Fi, TV, Climatisation	Exécutive	t	Aucun problème	70
20	501	2	600.00	4	Wi-Fi, TV, Climatisation	Suite Présidentielle	t	Aucun problème	70
23	103	3	220.00	4	Wi-Fi, TV, Climatisation	Standard Plus	t	Aucun problème	70
26	301	3	300.00	4	Wi-Fi, TV, Climatisation	Suite	t	Aucun problème	70
70	501	7	550.00	4	Wi-Fi, TV, Climatisation	Gouverneur Suite	t	Aucun problème	70
73	103	8	220.00	4	Wi-Fi, TV, Climatisation	Loft	t	Aucun problème	70
76	301	8	280.00	4	Wi-Fi, TV, Climatisation	Studio Large	t	Aucun problème	70
80	501	8	400.00	4	Wi-Fi, TV, Climatisation	Creative Suite	t	Aucun problème	70
30	501	3	450.00	4	Wi-Fi, TV, Climatisation	Luxe	t	Aucun problème	70
33	1003	4	800.00	4	Wi-Fi, TV, Climatisation	Grand Suite	t	Aucun problème	70
36	1201	4	950.00	4	Wi-Fi, TV, Climatisation	Royal Suite	t	Aucun problème	70
40	1401	4	1200.00	4	Wi-Fi, TV, Climatisation	Skyline Suite	t	Aucun problème	70
43	103	5	350.00	4	Wi-Fi, TV, Climatisation	Famille	t	Aucun problème	70
46	301	5	450.00	4	Wi-Fi, TV, Climatisation	Premium	t	Aucun problème	70
50	501	5	700.00	4	Wi-Fi, TV, Climatisation	Panorama Suite	t	Aucun problème	70
53	103	6	500.00	4	Wi-Fi, TV, Climatisation	Chalet Style	t	Aucun problème	70
56	301	6	650.00	4	Wi-Fi, TV, Climatisation	Alpin Suite	t	Aucun problème	70
60	501	6	900.00	4	Wi-Fi, TV, Climatisation	Sommet Suite	t	Aucun problème	70
63	103	7	280.00	4	Wi-Fi, TV, Climatisation	Suite Urbaine	t	Aucun problème	70
66	301	7	350.00	4	Wi-Fi, TV, Climatisation	Diplomate Suite	t	Aucun problème	70
2	102	1	150.00	2	Wi-Fi, TV, Climatisation	Vue Château	f	Aucun problème	40
4	201	1	180.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
5	202	1	180.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
7	302	1	120.00	1	Wi-Fi, TV, Climatisation	Simple	f	Aucun problème	25
8	401	1	200.00	2	Wi-Fi, TV, Climatisation	Vue Fleuve	f	Aucun problème	40
9	402	1	200.00	2	Wi-Fi, TV, Climatisation	Vue Fleuve	f	Aucun problème	40
11	101	2	210.00	2	Wi-Fi, TV, Climatisation	Vue Ville	f	Aucun problème	40
12	102	2	210.00	2	Wi-Fi, TV, Climatisation	Vue Ville	f	Aucun problème	40
14	201	2	190.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
15	202	2	190.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
17	302	2	150.00	1	Wi-Fi, TV, Climatisation	Simple	f	Aucun problème	25
18	401	2	250.00	2	Wi-Fi, TV, Climatisation	Vue Mont-Royal	f	Aucun problème	40
19	402	2	250.00	2	Wi-Fi, TV, Climatisation	Vue Mont-Royal	f	Aucun problème	40
21	101	3	140.00	2	Wi-Fi, TV, Climatisation	Vue Jardin	f	Aucun problème	40
22	102	3	140.00	2	Wi-Fi, TV, Climatisation	Vue Jardin	f	Aucun problème	40
24	201	3	130.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
25	202	3	130.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
27	302	3	110.00	1	Wi-Fi, TV, Climatisation	Simple	f	Aucun problème	25
28	401	3	170.00	2	Wi-Fi, TV, Climatisation	Vue Piscine	f	Aucun problème	40
68	401	7	210.00	2	Wi-Fi, TV, Climatisation	Vue Canal	f	Aucun problème	40
69	402	7	210.00	2	Wi-Fi, TV, Climatisation	Vue Canal	f	Aucun problème	40
71	101	8	145.00	2	Wi-Fi, TV, Climatisation	Moderne	f	Aucun problème	40
72	102	8	145.00	2	Wi-Fi, TV, Climatisation	Moderne	f	Aucun problème	40
74	201	8	135.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
75	202	8	135.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
77	302	8	115.00	1	Wi-Fi, TV, Climatisation	Simple Chic	f	Aucun problème	25
78	401	8	160.00	2	Wi-Fi, TV, Climatisation	Vue Rue	f	Aucun problème	40
79	402	8	160.00	2	Wi-Fi, TV, Climatisation	Vue Rue	f	Aucun problème	40
29	402	3	170.00	2	Wi-Fi, TV, Climatisation	Vue Piscine	f	Aucun problème	40
31	1001	4	550.00	2	Wi-Fi, TV, Climatisation	Vue Tour CN	f	Aucun problème	40
32	1002	4	550.00	2	Wi-Fi, TV, Climatisation	Vue Tour CN	f	Aucun problème	40
34	1101	4	500.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
35	1102	4	500.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
37	1202	4	450.00	1	Wi-Fi, TV, Climatisation	Simple Deluxe	f	Aucun problème	25
38	1301	4	600.00	2	Wi-Fi, TV, Climatisation	Vue Lac	f	Aucun problème	40
39	1302	4	600.00	2	Wi-Fi, TV, Climatisation	Vue Lac	f	Aucun problème	40
41	101	5	230.00	2	Wi-Fi, TV, Climatisation	Vue Baie	f	Aucun problème	40
42	102	5	230.00	2	Wi-Fi, TV, Climatisation	Vue Baie	f	Aucun problème	40
44	201	5	210.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
45	202	5	210.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
47	302	5	170.00	1	Wi-Fi, TV, Climatisation	Simple	f	Aucun problème	25
48	401	5	280.00	2	Wi-Fi, TV, Climatisation	Vue Montagne	f	Aucun problème	40
49	402	5	280.00	2	Wi-Fi, TV, Climatisation	Vue Montagne	f	Aucun problème	40
51	101	6	350.00	2	Wi-Fi, TV, Climatisation	Vue Forêt	f	Aucun problème	40
52	102	6	350.00	2	Wi-Fi, TV, Climatisation	Vue Forêt	f	Aucun problème	40
54	201	6	320.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
55	202	6	320.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
57	302	6	280.00	1	Wi-Fi, TV, Climatisation	Simple	f	Aucun problème	25
58	401	6	420.00	2	Wi-Fi, TV, Climatisation	Vue Glacier	f	Aucun problème	40
59	402	6	420.00	2	Wi-Fi, TV, Climatisation	Vue Glacier	f	Aucun problème	40
61	101	7	185.00	2	Wi-Fi, TV, Climatisation	Vue Parlement	f	Aucun problème	40
62	102	7	185.00	2	Wi-Fi, TV, Climatisation	Vue Parlement	f	Aucun problème	40
64	201	7	165.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
65	202	7	165.00	2	Wi-Fi, TV, Climatisation	Standard	f	Aucun problème	40
67	302	7	130.00	1	Wi-Fi, TV, Climatisation	Simple	f	Aucun problème	25
\.


--
-- TOC entry 3899 (class 0 OID 34733)
-- Dependencies: 229
-- Data for Name: reservation; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reservation (reservation_id, room_number, start_date, end_date, customer_id, statut, checkin_employee_id, hotel_number) FROM stdin;
\.


--
-- TOC entry 3895 (class 0 OID 34618)
-- Dependencies: 225
-- Data for Name: reservation_archive; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reservation_archive (reservation_id, customer_sin, hotel_room_id, status, start_date, end_date, deleted_at) FROM stdin;
32	34	1101	OCCUPÉ	2026-04-10	2026-04-14	2026-04-10 14:09:55.798746
32	34	1101	ANNULÉ	2026-04-10	2026-04-14	2026-04-10 14:10:46.694416
30	32	101	ANNULÉ	2026-04-10	2026-04-11	2026-04-10 14:52:46.703335
\.


--
-- TOC entry 3893 (class 0 OID 34560)
-- Dependencies: 222
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (social_insurance_number, first_name, middle_name, last_name, street_number, street_name, apt_number, city, state, zip_code, email, phone_number, creation_date) FROM stdin;
100000001	Manager1	\N	Lastname1	1	Main St	\N	Ottawa	ON	K1A0B1	mgr1@test.com	1234567890	2026-04-09
100000002	Manager2	\N	Lastname2	2	Main St	\N	Ottawa	ON	K1A0B1	mgr2@test.com	1234567890	2026-04-09
100000003	Manager3	\N	Lastname3	3	Main St	\N	Ottawa	ON	K1A0B1	mgr3@test.com	1234567890	2026-04-09
100000004	Manager4	\N	Lastname4	4	Main St	\N	Ottawa	ON	K1A0B1	mgr4@test.com	1234567890	2026-04-09
100000005	Manager5	\N	Lastname5	5	Main St	\N	Ottawa	ON	K1A0B1	mgr5@test.com	1234567890	2026-04-09
100000006	Manager6	\N	Lastname6	6	Main St	\N	Ottawa	ON	K1A0B1	mgr6@test.com	1234567890	2026-04-09
100000007	Manager7	\N	Lastname7	7	Main St	\N	Ottawa	ON	K1A0B1	mgr7@test.com	1234567890	2026-04-09
100000008	Manager8	\N	Lastname8	8	Main St	\N	Ottawa	ON	K1A0B1	mgr8@test.com	1234567890	2026-04-09
100000009	Manager9	\N	Lastname9	9	Main St	\N	Ottawa	ON	K1A0B1	mgr9@test.com	1234567890	2026-04-09
100000010	Manager10	\N	Lastname10	10	Main St	\N	Ottawa	ON	K1A0B1	mgr10@test.com	1234567890	2026-04-09
100000011	Manager11	\N	Lastname11	11	Main St	\N	Ottawa	ON	K1A0B1	mgr11@test.com	1234567890	2026-04-09
100000012	Manager12	\N	Lastname12	12	Main St	\N	Ottawa	ON	K1A0B1	mgr12@test.com	1234567890	2026-04-09
100000013	Manager13	\N	Lastname13	13	Main St	\N	Ottawa	ON	K1A0B1	mgr13@test.com	1234567890	2026-04-09
100000014	Manager14	\N	Lastname14	14	Main St	\N	Ottawa	ON	K1A0B1	mgr14@test.com	1234567890	2026-04-09
100000015	Manager15	\N	Lastname15	15	Main St	\N	Ottawa	ON	K1A0B1	mgr15@test.com	1234567890	2026-04-09
100000016	Manager16	\N	Lastname16	16	Main St	\N	Ottawa	ON	K1A0B1	mgr16@test.com	1234567890	2026-04-09
100000017	Manager17	\N	Lastname17	17	Main St	\N	Ottawa	ON	K1A0B1	mgr17@test.com	1234567890	2026-04-09
100000018	Manager18	\N	Lastname18	18	Main St	\N	Ottawa	ON	K1A0B1	mgr18@test.com	1234567890	2026-04-09
100000019	Manager19	\N	Lastname19	19	Main St	\N	Ottawa	ON	K1A0B1	mgr19@test.com	1234567890	2026-04-09
100000020	Manager20	\N	Lastname20	20	Main St	\N	Ottawa	ON	K1A0B1	mgr20@test.com	1234567890	2026-04-09
100000021	Manager21	\N	Lastname21	21	Main St	\N	Ottawa	ON	K1A0B1	mgr21@test.com	1234567890	2026-04-09
100000022	Manager22	\N	Lastname22	22	Main St	\N	Ottawa	ON	K1A0B1	mgr22@test.com	1234567890	2026-04-09
100000023	Manager23	\N	Lastname23	23	Main St	\N	Ottawa	ON	K1A0B1	mgr23@test.com	1234567890	2026-04-09
100000024	Manager24	\N	Lastname24	24	Main St	\N	Ottawa	ON	K1A0B1	mgr24@test.com	1234567890	2026-04-09
100000025	Manager25	\N	Lastname25	25	Main St	\N	Ottawa	ON	K1A0B1	mgr25@test.com	1234567890	2026-04-09
100000026	Manager26	\N	Lastname26	26	Main St	\N	Ottawa	ON	K1A0B1	mgr26@test.com	1234567890	2026-04-09
100000027	Manager27	\N	Lastname27	27	Main St	\N	Ottawa	ON	K1A0B1	mgr27@test.com	1234567890	2026-04-09
100000028	Manager28	\N	Lastname28	28	Main St	\N	Ottawa	ON	K1A0B1	mgr28@test.com	1234567890	2026-04-09
100000029	Manager29	\N	Lastname29	29	Main St	\N	Ottawa	ON	K1A0B1	mgr29@test.com	1234567890	2026-04-09
100000030	Manager30	\N	Lastname30	30	Main St	\N	Ottawa	ON	K1A0B1	mgr30@test.com	1234567890	2026-04-09
100000031	Manager31	\N	Lastname31	31	Main St	\N	Ottawa	ON	K1A0B1	mgr31@test.com	1234567890	2026-04-09
100000032	Manager32	\N	Lastname32	32	Main St	\N	Ottawa	ON	K1A0B1	mgr32@test.com	1234567890	2026-04-09
100000033	Manager33	\N	Lastname33	33	Main St	\N	Ottawa	ON	K1A0B1	mgr33@test.com	1234567890	2026-04-09
100000034	Manager34	\N	Lastname34	34	Main St	\N	Ottawa	ON	K1A0B1	mgr34@test.com	1234567890	2026-04-09
100000035	Manager35	\N	Lastname35	35	Main St	\N	Ottawa	ON	K1A0B1	mgr35@test.com	1234567890	2026-04-09
100000036	Manager36	\N	Lastname36	36	Main St	\N	Ottawa	ON	K1A0B1	mgr36@test.com	1234567890	2026-04-09
100000037	Manager37	\N	Lastname37	37	Main St	\N	Ottawa	ON	K1A0B1	mgr37@test.com	1234567890	2026-04-09
100000038	Manager38	\N	Lastname38	38	Main St	\N	Ottawa	ON	K1A0B1	mgr38@test.com	1234567890	2026-04-09
100000039	Manager39	\N	Lastname39	39	Main St	\N	Ottawa	ON	K1A0B1	mgr39@test.com	1234567890	2026-04-09
100000040	Manager40	\N	Lastname40	40	Main St	\N	Ottawa	ON	K1A0B1	mgr40@test.com	1234567890	2026-04-09
1001	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
1002	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
1003	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
1004	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
1005	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
1006	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
1007	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2001	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2002	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2003	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2004	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2005	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2006	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
2007	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3001	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3002	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3003	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3004	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3005	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3006	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3007	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4001	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4002	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4003	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4004	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4005	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4006	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4007	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5001	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5002	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5003	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5004	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5005	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5006	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
5007	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
6001	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
6002	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
6003	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
6004	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
6005	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
6006	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
6007	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
7001	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
7002	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
7003	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
7004	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
7005	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
7006	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
7007	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8001	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8002	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8003	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8004	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8005	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8006	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
8007	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- TOC entry 3907 (class 0 OID 0)
-- Dependencies: 226
-- Name: customer_customer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customer_customer_id_seq', 36, true);


--
-- TOC entry 3908 (class 0 OID 0)
-- Dependencies: 228
-- Name: reservation_reservation_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.reservation_reservation_id_seq', 34, true);


--
-- TOC entry 3730 (class 2606 OID 34731)
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (customer_id);


--
-- TOC entry 3727 (class 2606 OID 34571)
-- Name: employee employee_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_pkey PRIMARY KEY (employee_id);


--
-- TOC entry 3717 (class 2606 OID 34535)
-- Name: hotel_chain hotel_chain_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hotel_chain
    ADD CONSTRAINT hotel_chain_pkey PRIMARY KEY (chain_number);


--
-- TOC entry 3719 (class 2606 OID 34541)
-- Name: hotel hotel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hotel
    ADD CONSTRAINT hotel_pkey PRIMARY KEY (hotel_number);


--
-- TOC entry 3722 (class 2606 OID 34554)
-- Name: hotel_room hotel_room_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hotel_room
    ADD CONSTRAINT hotel_room_pkey PRIMARY KEY (hotel_room_id);


--
-- TOC entry 3733 (class 2606 OID 34745)
-- Name: reservation reservation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT reservation_pkey PRIMARY KEY (reservation_id);


--
-- TOC entry 3725 (class 2606 OID 34565)
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (social_insurance_number);


--
-- TOC entry 3728 (class 1259 OID 34615)
-- Name: idx_employee_role; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_employee_role ON public.employee USING btree (role);


--
-- TOC entry 3720 (class 1259 OID 34793)
-- Name: idx_hotel_city; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hotel_city ON public.hotel USING btree (city);


--
-- TOC entry 3723 (class 1259 OID 34613)
-- Name: idx_hotel_room_price; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_hotel_room_price ON public.hotel_room USING btree (price);


--
-- TOC entry 3731 (class 1259 OID 34794)
-- Name: idx_reservation_dates; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_reservation_dates ON public.reservation USING btree (start_date, end_date);


--
-- TOC entry 3737 (class 2606 OID 34577)
-- Name: employee employee_hotel_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_hotel_number_fkey FOREIGN KEY (hotel_number) REFERENCES public.hotel(hotel_number);


--
-- TOC entry 3738 (class 2606 OID 34572)
-- Name: employee employee_social_insurance_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employee
    ADD CONSTRAINT employee_social_insurance_number_fkey FOREIGN KEY (social_insurance_number) REFERENCES public."user"(social_insurance_number);


--
-- TOC entry 3739 (class 2606 OID 34753)
-- Name: reservation fk_checkin_employee; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT fk_checkin_employee FOREIGN KEY (checkin_employee_id) REFERENCES public.employee(employee_id) ON DELETE SET NULL;


--
-- TOC entry 3740 (class 2606 OID 34746)
-- Name: reservation fk_customer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation
    ADD CONSTRAINT fk_customer FOREIGN KEY (customer_id) REFERENCES public.customer(customer_id) ON DELETE CASCADE;


--
-- TOC entry 3734 (class 2606 OID 34582)
-- Name: hotel fk_manager; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hotel
    ADD CONSTRAINT fk_manager FOREIGN KEY (manager_id) REFERENCES public.employee(employee_id);


--
-- TOC entry 3735 (class 2606 OID 34542)
-- Name: hotel hotel_chain_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hotel
    ADD CONSTRAINT hotel_chain_number_fkey FOREIGN KEY (chain_number) REFERENCES public.hotel_chain(chain_number);


--
-- TOC entry 3736 (class 2606 OID 34555)
-- Name: hotel_room hotel_room_hotel_number_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.hotel_room
    ADD CONSTRAINT hotel_room_hotel_number_fkey FOREIGN KEY (hotel_number) REFERENCES public.hotel(hotel_number);


-- Completed on 2026-04-10 16:05:31 EDT

--
-- PostgreSQL database dump complete
--

\unrestrict FDP2H2XRoHaa6dRpoqjH48DSrBZcY96hSj04gqH0aURjsWZdcHmdVOco4FaTWEf

