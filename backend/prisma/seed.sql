--
-- PostgreSQL database dump
--

\restrict EnUI3yZzwuxllzyc6ZWAHwDSRMx4Jr4AKAmm1TLjGC4jPSIcAGoI1IGRKg12KXd

-- Dumped from database version 16.13 (Debian 16.13-1.pgdg13+1)
-- Dumped by pg_dump version 18.3

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
-- Data for Name: Region; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Region" (id, name, city, address, "mapUrl", "regionImgUrl", "createdAt") VALUES ('74cad3a8-bf86-4cf7-a398-05446f2cb332', 'Clinic Majapahit Semarang', 'Semarang', 'Jl Majapahit No 5', NULL, NULL, '2026-04-07 09:53:50.156');
INSERT INTO public."Region" (id, name, city, address, "mapUrl", "regionImgUrl", "createdAt") VALUES ('3b3ebea0-3c93-48c2-9bd2-36dd7e71b4c0', 'Clinic Cakung Jakarta', 'Jakarta Timur', 'Jl Soedirman No 1', NULL, NULL, '2026-04-08 07:25:31.241');
INSERT INTO public."Region" (id, name, city, address, "mapUrl", "regionImgUrl", "createdAt") VALUES ('bff8c53b-1d91-4dc4-9512-2eceb74a6580', 'Clinic Asia Afrika Bandung', 'Bandung', 'Jl Asia Afrika No 4', NULL, NULL, '2026-04-09 04:23:07.284');


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."User" (id, email, password, role, "createdAt") VALUES ('7ff7a18a-10aa-43f3-9a46-5fc0cc24ba27', 'admin1@ksclinic.com', '$2b$10$yXKKDcF81lb5TGyXaOM6..pOW/VTCsSmMZWIjoexNlDEkO82U9lAC', 'ADMIN', '2026-04-07 09:34:47.909');
INSERT INTO public."User" (id, email, password, role, "createdAt") VALUES ('7e41db6e-7cb0-4e40-84bd-a43f27be500e', 'brucebanner@ksclinic.com', '$2b$10$CuuBFn7L4dzE/i3GwhR5UejWZ8fEtdNoiKu99kVw5BJKByhqXSAZy', 'DOCTOR', '2026-04-07 09:55:26.874');
INSERT INTO public."User" (id, email, password, role, "createdAt") VALUES ('5137326f-1bc6-417c-bbff-e427fd4d77d8', 'senku@ksclinic.com', '$2b$10$GeS1RHATV1AIAwvoLlzQ5OgMrU338XFweTdNZgao6C9op6sv1ehBq', 'DOCTOR', '2026-04-08 07:23:56.635');
INSERT INTO public."User" (id, email, password, role, "createdAt") VALUES ('50a0d36c-c8fa-4ff8-8ccc-59d85a1b10e7', 'saitama@ksclinic.com', '$2b$10$EHkKvsKZZx3LKB0jBcg4O.F33O6QKo/CLSyhg.WwMcrpi.QQwnuPe', 'PATIENT', '2026-04-09 04:18:30.813');
INSERT INTO public."User" (id, email, password, role, "createdAt") VALUES ('b19395cb-c593-47d7-a01b-7c01b36da0d5', 'drwho@ksclinic.com', '$2b$10$k1HcJIVP/6CUl3iLolmM9.ibZze1F66erhwocvWvdNusTGNwhUxeW', 'DOCTOR', '2026-04-09 15:28:24.965');
INSERT INTO public."User" (id, email, password, role, "createdAt") VALUES ('cb61f20f-3397-4976-9ed2-59ef6a65119e', 'riorasyid@ksclinic.com', '$2b$10$w66IpnTpGPusH4.DuLRrP.S2myCCwUhw4fYOAsyevf15ws4CCa2hC', 'PATIENT', '2026-04-08 14:06:10.95');


--
-- Data for Name: DoctorProfile; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."DoctorProfile" (id, name, "phoneNumber", "profileImgUrl", "userId", specialty, "regionId") VALUES ('fb268f8e-50f5-4273-a385-7403f47099b1', 'Dr. Bruce Banner', '+628123123126', NULL, '7e41db6e-7cb0-4e40-84bd-a43f27be500e', 'Neurology, Biotechnology', '74cad3a8-bf86-4cf7-a398-05446f2cb332');
INSERT INTO public."DoctorProfile" (id, name, "phoneNumber", "profileImgUrl", "userId", specialty, "regionId") VALUES ('4e9565be-b64a-4d0e-abac-5595fd64d5c9', 'Dr. Stone Senku', '+628123123126', NULL, '5137326f-1bc6-417c-bbff-e427fd4d77d8', 'Surgery', '3b3ebea0-3c93-48c2-9bd2-36dd7e71b4c0');
INSERT INTO public."DoctorProfile" (id, name, "phoneNumber", "profileImgUrl", "userId", specialty, "regionId") VALUES ('9b2c5dde-f074-4c97-a9aa-be8ae69bbfbd', 'Dr. Who', '+628123123126', NULL, 'b19395cb-c593-47d7-a01b-7c01b36da0d5', 'Neurology', '74cad3a8-bf86-4cf7-a398-05446f2cb332');


--
-- Data for Name: DoctorSchedule; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."DoctorSchedule" (id, "dayOfWeek", "startTime", "endTime", "slotDuration", "doctorId") VALUES ('4e33c97b-9a0f-4026-bafa-60b7e733aa54', 1, '08:00', '15:00', 30, '4e9565be-b64a-4d0e-abac-5595fd64d5c9');
INSERT INTO public."DoctorSchedule" (id, "dayOfWeek", "startTime", "endTime", "slotDuration", "doctorId") VALUES ('7019529e-07a2-4336-aaa1-88dd46e55183', 2, '09:00', '16:00', 30, '4e9565be-b64a-4d0e-abac-5595fd64d5c9');
INSERT INTO public."DoctorSchedule" (id, "dayOfWeek", "startTime", "endTime", "slotDuration", "doctorId") VALUES ('68f63c72-1e10-453a-aa6c-d00248e83fee', 3, '09:00', '16:00', 30, '4e9565be-b64a-4d0e-abac-5595fd64d5c9');
INSERT INTO public."DoctorSchedule" (id, "dayOfWeek", "startTime", "endTime", "slotDuration", "doctorId") VALUES ('f1103716-8311-4ec3-8b7f-980b026bc21a', 5, '09:00', '16:00', 30, '9b2c5dde-f074-4c97-a9aa-be8ae69bbfbd');


--
-- Data for Name: PatientProfile; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."PatientProfile" (id, name, "phoneNumber", "profileImgUrl", "userId", height, weight, "bloodType", "dateOfBirth") VALUES ('ed180b14-0940-4aaf-9aa1-66d99709d9b2', 'Admin Rio Rasyid', '+628123123124', NULL, '7ff7a18a-10aa-43f3-9a46-5fc0cc24ba27', NULL, NULL, NULL, NULL);
INSERT INTO public."PatientProfile" (id, name, "phoneNumber", "profileImgUrl", "userId", height, weight, "bloodType", "dateOfBirth") VALUES ('c01be10f-1210-4e2c-a2ab-b637a8bcbe34', 'Gojo Satoru', '+628123123126', NULL, '50a0d36c-c8fa-4ff8-8ccc-59d85a1b10e7', 192.6, 76.8, 'O', '2001-07-15 00:00:00');
INSERT INTO public."PatientProfile" (id, name, "phoneNumber", "profileImgUrl", "userId", height, weight, "bloodType", "dateOfBirth") VALUES ('1955b807-6d71-45a7-b65e-edebf58aa057', 'Rio Al Rasyid', '+628123123125', NULL, 'cb61f20f-3397-4976-9ed2-59ef6a65119e', 173, 61, 'O', '2001-07-15 00:00:00');


--
-- Data for Name: Encounter; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."Encounter" (id, date, reason, notes, "createdAt", "patientId", "doctorId", "currentStatus", "endTime", "startTime") VALUES ('ef1f7464-ce0f-47c9-a172-2cf943347f48', '2026-04-13 00:00:00', 'Medical Checkup/Control', 'Cortisol Level checks', '2026-04-08 15:01:59.521', '1955b807-6d71-45a7-b65e-edebf58aa057', '4e9565be-b64a-4d0e-abac-5595fd64d5c9', 'CANCELLED', '08:30', '08:00');
INSERT INTO public."Encounter" (id, date, reason, notes, "createdAt", "patientId", "doctorId", "currentStatus", "endTime", "startTime") VALUES ('410954f0-6b3a-4299-adac-0250c32d0ce0', '2026-04-13 00:00:00', 'Medical Checkup/Control', 'Cortisol Level checks', '2026-04-09 05:12:31.551', 'c01be10f-1210-4e2c-a2ab-b637a8bcbe34', '4e9565be-b64a-4d0e-abac-5595fd64d5c9', 'CANCELLED', '13:30', '13:00');
INSERT INTO public."Encounter" (id, date, reason, notes, "createdAt", "patientId", "doctorId", "currentStatus", "endTime", "startTime") VALUES ('78bb95c0-8447-4d20-a21b-9892484e2846', '2026-04-10 00:00:00', 'General Consultation', 'Consult about headache', '2026-04-10 07:17:18.022', '1955b807-6d71-45a7-b65e-edebf58aa057', '9b2c5dde-f074-4c97-a9aa-be8ae69bbfbd', 'PENDING', '16:00', '15:30');
INSERT INTO public."Encounter" (id, date, reason, notes, "createdAt", "patientId", "doctorId", "currentStatus", "endTime", "startTime") VALUES ('ed8dedda-12ae-4d20-b633-afc6a540206d', '2026-04-13 00:00:00', 'Medical Checkup/Control', 'Cortisol Level checks', '2026-04-08 16:23:45.974', '1955b807-6d71-45a7-b65e-edebf58aa057', '4e9565be-b64a-4d0e-abac-5595fd64d5c9', 'CANCELLED', '12:30', '12:00');
INSERT INTO public."Encounter" (id, date, reason, notes, "createdAt", "patientId", "doctorId", "currentStatus", "endTime", "startTime") VALUES ('8da4f0ba-e05a-48f8-9e22-3466af127649', '2026-04-13 00:00:00', 'Medical Checkup/Control', 'Sugar Level Check', '2026-04-10 07:40:00.759', '1955b807-6d71-45a7-b65e-edebf58aa057', '4e9565be-b64a-4d0e-abac-5595fd64d5c9', 'COMPLETED', '08:30', '08:00');
INSERT INTO public."Encounter" (id, date, reason, notes, "createdAt", "patientId", "doctorId", "currentStatus", "endTime", "startTime") VALUES ('beab74e3-2e70-4bf1-8486-5afdb73858a7', '2026-04-17 00:00:00', 'General Consultation', 'Consult about stomacache', '2026-04-10 11:13:02.497', '1955b807-6d71-45a7-b65e-edebf58aa057', '9b2c5dde-f074-4c97-a9aa-be8ae69bbfbd', 'PENDING', '09:30', '09:00');
INSERT INTO public."Encounter" (id, date, reason, notes, "createdAt", "patientId", "doctorId", "currentStatus", "endTime", "startTime") VALUES ('4a3c917f-7534-41f2-a5ef-3d475328c59f', '2026-04-13 00:00:00', 'General Consultation', 'Consult about tootache', '2026-04-10 11:21:31.944', '1955b807-6d71-45a7-b65e-edebf58aa057', '4e9565be-b64a-4d0e-abac-5595fd64d5c9', 'COMPLETED', '13:30', '13:00');


--
-- Data for Name: StatusUpdate; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."StatusUpdate" (id, status, note, "createdAt", "encounterId", "createdBy") VALUES ('6e0d33d3-1810-4b32-959b-535ccea2e142', 'PENDING', 'Initial booking created by patient', '2026-04-08 15:01:59.521', 'ef1f7464-ce0f-47c9-a172-2cf943347f48', 'cb61f20f-3397-4976-9ed2-59ef6a65119e');
INSERT INTO public."StatusUpdate" (id, status, note, "createdAt", "encounterId", "createdBy") VALUES ('7b536cfe-c01f-4254-8e84-1ee8d3b878f4', 'PENDING', 'Initial booking created by patient', '2026-04-08 16:23:45.974', 'ed8dedda-12ae-4d20-b633-afc6a540206d', 'cb61f20f-3397-4976-9ed2-59ef6a65119e');
INSERT INTO public."StatusUpdate" (id, status, note, "createdAt", "encounterId", "createdBy") VALUES ('4b6deed8-03d1-4bd6-af04-f929d5e41287', 'CANCELLED', 'Doctor is on sickday off', '2026-04-09 04:03:01.83', 'ef1f7464-ce0f-47c9-a172-2cf943347f48', 'PATIENT-cb61f20f-3397-4976-9ed2-59ef6a65119e');
INSERT INTO public."StatusUpdate" (id, status, note, "createdAt", "encounterId", "createdBy") VALUES ('deb06b52-1900-47f6-bc4f-eb8ce2f43d6f', 'PENDING', 'Initial booking created by patient', '2026-04-09 05:12:31.551', '410954f0-6b3a-4299-adac-0250c32d0ce0', 'PATIENT-50a0d36c-c8fa-4ff8-8ccc-59d85a1b10e7');
INSERT INTO public."StatusUpdate" (id, status, note, "createdAt", "encounterId", "createdBy") VALUES ('095669d2-703b-46fc-a3f7-bedb0af18eba', 'CANCELLED', 'Doctor is on holiday', '2026-04-09 05:18:40.052', '410954f0-6b3a-4299-adac-0250c32d0ce0', 'PATIENT-50a0d36c-c8fa-4ff8-8ccc-59d85a1b10e7');
INSERT INTO public."StatusUpdate" (id, status, note, "createdAt", "encounterId", "createdBy") VALUES ('1142b7c2-8612-499d-b309-42bc2307aa67', 'PENDING', 'Initial booking created by patient', '2026-04-10 07:17:18.022', '78bb95c0-8447-4d20-a21b-9892484e2846', 'PATIENT-cb61f20f-3397-4976-9ed2-59ef6a65119e');
INSERT INTO public."StatusUpdate" (id, status, note, "createdAt", "encounterId", "createdBy") VALUES ('5241761f-554e-4cb0-88c5-9e2e9cb6051f', 'PENDING', 'Initial booking created by patient', '2026-04-10 07:40:00.759', '8da4f0ba-e05a-48f8-9e22-3466af127649', 'PATIENT-cb61f20f-3397-4976-9ed2-59ef6a65119e');
INSERT INTO public."StatusUpdate" (id, status, note, "createdAt", "encounterId", "createdBy") VALUES ('50d7b694-14bd-4275-a07c-3729aec3eb41', 'CANCELLED', 'Doctor is on vacation', '2026-04-10 08:04:42.638', 'ed8dedda-12ae-4d20-b633-afc6a540206d', 'PATIENT-cb61f20f-3397-4976-9ed2-59ef6a65119e');
INSERT INTO public."StatusUpdate" (id, status, note, "createdAt", "encounterId", "createdBy") VALUES ('571d10c1-a6d1-4361-b0f4-abe91c7b7e91', 'CONFIRMED', 'Confirmed, please visit the clinic', '2026-04-10 10:49:13.428', '8da4f0ba-e05a-48f8-9e22-3466af127649', 'DOCTOR-5137326f-1bc6-417c-bbff-e427fd4d77d8');
INSERT INTO public."StatusUpdate" (id, status, note, "createdAt", "encounterId", "createdBy") VALUES ('56312168-96e5-44f8-a54a-c3bdf4b4eb35', 'COMPLETED', 'Patient has been consulted', '2026-04-10 10:59:30.293', '8da4f0ba-e05a-48f8-9e22-3466af127649', 'DOCTOR-5137326f-1bc6-417c-bbff-e427fd4d77d8');
INSERT INTO public."StatusUpdate" (id, status, note, "createdAt", "encounterId", "createdBy") VALUES ('f402aaa3-8e98-46a5-9c5e-7d3365c2fad0', 'PENDING', 'Initial booking created by patient', '2026-04-10 11:13:02.497', 'beab74e3-2e70-4bf1-8486-5afdb73858a7', 'PATIENT-cb61f20f-3397-4976-9ed2-59ef6a65119e');
INSERT INTO public."StatusUpdate" (id, status, note, "createdAt", "encounterId", "createdBy") VALUES ('d26a4d68-a793-4434-873f-09775282cf6d', 'PENDING', 'Initial booking created by patient', '2026-04-10 11:21:31.944', '4a3c917f-7534-41f2-a5ef-3d475328c59f', 'PATIENT-cb61f20f-3397-4976-9ed2-59ef6a65119e');
INSERT INTO public."StatusUpdate" (id, status, note, "createdAt", "encounterId", "createdBy") VALUES ('53a8bc53-9f2d-4e72-bdb8-3b16ab3b2ec7', 'CONFIRMED', 'Confirmed, please visit clinic', '2026-04-10 11:24:32.112', '4a3c917f-7534-41f2-a5ef-3d475328c59f', 'DOCTOR-5137326f-1bc6-417c-bbff-e427fd4d77d8');
INSERT INTO public."StatusUpdate" (id, status, note, "createdAt", "encounterId", "createdBy") VALUES ('d7bd6a40-8348-4c07-9001-d73e764796c2', 'COMPLETED', 'Consulation Completed', '2026-04-10 11:29:33.463', '4a3c917f-7534-41f2-a5ef-3d475328c59f', 'DOCTOR-5137326f-1bc6-417c-bbff-e427fd4d77d8');


--
-- Data for Name: _prisma_migrations; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('c1d46c8d-c949-4571-8ab1-11812cfd68ea', '8103d666a25dcd2e0c5fedeb193865a21cff541e0fafd41556bb9ddc623689a0', '2026-04-07 05:45:38.443419+00', '20260407054538_init', NULL, NULL, '2026-04-07 05:45:38.238277+00', 1);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('f4794a87-d9d7-4019-b5bb-322ada5392e1', 'b477243dd0b01bd19d9cd646dd51ed18e034cef6cf73fe5dcb20cd2851589cba', '2026-04-07 07:51:16.944853+00', '20260407075116_set_phone_default_city_unique', NULL, NULL, '2026-04-07 07:51:16.923767+00', 1);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('12e3de16-463a-465b-b37e-0e1932ad9669', '3bc8c2e63288e6e7384b55b2aa6909705265ca17f47f0fea46cd4913ffe9a4af', '2026-04-07 08:02:31.024141+00', '20260407080230_adjust_region_field', NULL, NULL, '2026-04-07 08:02:30.983756+00', 1);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('93f9973a-a103-4b08-b524-de2161cd3bdd', '6e68d1f2f1ab721ac1dbf79c1eea957d9ac22b9d803d34d4c58f0c8a400e06a8', '2026-04-07 09:28:35.727797+00', '20260407092835_add_user_dob', NULL, NULL, '2026-04-07 09:28:35.71659+00', 1);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('0f193946-ea46-45a5-8765-7e5133611670', 'd0155bacd221cefa46dcc1abefbe0984c26585b85a452c05d05e3231683208db', '2026-04-08 07:58:14.800542+00', '20260408075814_add_doctor_schedule', NULL, NULL, '2026-04-08 07:58:14.779854+00', 1);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('3b93c467-acd9-4c5c-80d5-38b44f601703', '9352aa2af370d035747509349b389c8f5ea87c59422f1e1976f71ec2a7267d55', '2026-04-08 08:36:28.898547+00', '20260408083628_add_current_booking_status', NULL, NULL, '2026-04-08 08:36:28.889824+00', 1);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('025c3937-d752-46ab-a87e-ca1e203d3156', '5a0f7617742b7a0a6b9e866a72ec9030d2ceed11a53fe93d62ae5e390ccfe1b8', '2026-04-08 13:16:35.448294+00', '20260408131635_add_start_end_time_encounter', NULL, NULL, '2026-04-08 13:16:35.431182+00', 1);
INSERT INTO public._prisma_migrations (id, checksum, finished_at, migration_name, logs, rolled_back_at, started_at, applied_steps_count) VALUES ('26712e5d-9a5c-4b49-92bb-34ceb0528e9c', 'bad88b84e9f2e245e5b4b11c23bef5fb0c8d428f1dd7956047f21e34434ac098', '2026-04-09 03:26:08.409353+00', '20260409032608_add_createdby_status_update', NULL, NULL, '2026-04-09 03:26:08.398456+00', 1);


--
-- PostgreSQL database dump complete
--

\unrestrict EnUI3yZzwuxllzyc6ZWAHwDSRMx4Jr4AKAmm1TLjGC4jPSIcAGoI1IGRKg12KXd

