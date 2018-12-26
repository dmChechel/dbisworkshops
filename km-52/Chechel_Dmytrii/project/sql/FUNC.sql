CREATE OR REPLACE PACKAGE MIGRATION_FILES_PACKAGE AS
  TYPE T_MIGRATION_FILES IS RECORD (
  LINK VARCHAR(255),
  MIGRATION_ID NUMBER,
  UPLOAD_TIMESTAMP TIMESTAMP(0),
    FILE_SIZE NUMBER
  );

  TYPE T_MIGRATION_FILES_TABLE IS TABLE OF T_MIGRATION_FILES;

  FUNCTION GET_MIGRATION_FILE(LINK IN MIGRATION_FILES.LINK%TYPE)
    RETURN T_MIGRATION_FILES_TABLE PIPELINED;
  FUNCTION GET_MIGRATION_FILES(MR_ID IN MIGRATION_REQUESTS.ID%TYPE)
    RETURN T_MIGRATION_FILES_TABLE PIPELINED;

  FUNCTION SET_NEW_FILE(LINK     IN MIGRATION_FILES.LINK%TYPE,
                 FILE_SIZE    IN MIGRATION_FILES.FILE_SIZE%TYPE,
                 MIGRATION_ID IN MIGRATION_FILES.MIGRATION_ID%TYPE
                 )
      RETURN T_MIGRATION_FILES_TABLE PIPELINED;;
END;

CREATE OR REPLACE PACKAGE BODY MIGRATION_FILES_PACKAGE AS
  FUNCTION GET_MIGRATION_FILE(LINK IN MIGRATION_FILES.LINK%TYPE)
    RETURN T_MIGRATION_FILES_TABLE PIPELINED AS
    CURSOR MY_CUR IS
      SELECT *
      FROM MIGRATION_FILES
      WHERE MIGRATION_FILES.LINK = LINK;
    BEGIN
      FOR CURR IN MY_CUR
      LOOP
        PIPE ROW (CURR);
      end loop;
    END;

  FUNCTION GET_MIGRATION_FILES(MR_ID IN MIGRATION_REQUESTS.ID%TYPE)
    RETURN T_MIGRATION_FILES_TABLE PIPELINED AS
    CURSOR MY_CURSOR IS
      SELECT *
      FROM MIGRATION_FILES
      WHERE MIGRATION_ID = MR_ID;
    BEGIN
      FOR REC IN MY_CURSOR
      LOOP
        PIPE ROW (REC);
      END LOOP;
    END;

 FUNCTION SET_NEW_FILE(LINK     IN MIGRATION_FILES.LINK%TYPE,
                 FILE_SIZE    IN MIGRATION_FILES.FILE_SIZE%TYPE,
                 MIGRATION_ID IN MIGRATION_FILES.MIGRATION_ID%TYPE
                 ) AS
    BEGIN
      INSERT INTO MIGRATION_FILES (LINK, FILE_SIZE, MIGRATION_ID) VALUES (LINK, FILE_SIZE, MIGRATION_ID);
    END;
END MIGRATION_FILES_PACKAGE;

CREATE OR REPLACE PACKAGE MIGRATION_REQUEST_PACKAGE AS
  TYPE T_MIGRATION_REQUEST IS RECORD (
  ID NUMBER,
  USER_EMAIL VARCHAR2(30 CHAR),
  UPLOAD_TIMESTAMP TIMESTAMP,
  DATABASE_ID NUMBER,
  DATABASE_NAME VARCHAR2(30)
  );

  TYPE T_MIGRATION_REQUEST_TABLE IS TABLE OF T_MIGRATION_REQUEST;

  FUNCTION GET_MIGRATION_REQUEST(MR_ID IN MIGRATION_REQUESTS.ID%TYPE)
    RETURN T_MIGRATION_REQUEST_TABLE PIPELINED;
  FUNCTION GET_MIGRATION_REQUESTS(EMAIL IN MIGRATION_REQUESTS.USER_EMAIL%TYPE)
    RETURN T_MIGRATION_REQUEST_TABLE PIPELINED;

 PROCEDURE CREATE_MIGRATION_REQUEST(EMAIL IN USERS.EMAIL%TYPE, DB_ID IN DATABASES.ID%TYPE);
END;

CREATE OR REPLACE PACKAGE BODY MIGRATION_REQUEST_PACKAGE AS
  FUNCTION GET_MIGRATION_REQUEST(MR_ID IN MIGRATION_REQUESTS.ID%TYPE)
    RETURN T_MIGRATION_REQUEST_TABLE PIPELINED AS
    CURSOR MY_CUR IS
      SELECT MIGRATION_REQUESTS.*, DATABASES.NAME
      FROM MIGRATION_REQUESTS
      LEFT JOIN DATABASES ON MIGRATION_REQUESTS.DATABASE_ID = DATABASES.ID
      WHERE MIGRATION_REQUESTS.ID = MR_ID
      ORDER BY UPLOAD_TIMESTAMP DESC;
    BEGIN
      FOR CURR IN MY_CUR
      LOOP
        PIPE ROW (CURR);
      end loop;
    END;

  FUNCTION GET_MIGRATION_REQUESTS(EMAIL IN MIGRATION_REQUESTS.USER_EMAIL%TYPE)
    RETURN T_MIGRATION_REQUEST_TABLE PIPELINED AS
    CURSOR MY_CURSOR IS
      SELECT MIGRATION_REQUESTS.*, DATABASES.NAME
      FROM MIGRATION_REQUESTS
      JOIN DATABASES ON MIGRATION_REQUESTS.DATABASE_ID = DATABASES.ID
      WHERE MIGRATION_REQUESTS.USER_EMAIL = EMAIL;
    BEGIN
      FOR REC IN MY_CURSOR
      LOOP
        PIPE ROW (REC);
      END LOOP;
    END;

    PROCEDURE CREATE_MIGRATION_REQUEST(EMAIL IN USERS.EMAIL%TYPE, DB_ID IN DATABASES.ID%TYPE) AS
    BEGIN
      INSERT INTO MIGRATION_REQUESTS (USER_EMAIL, DATABASE_ID) VALUES (EMAIL, DB_ID);
      COMMIT WORK;
    END;
END MIGRATION_REQUEST_PACKAGE;

CREATE OR REPLACE PACKAGE MIGRATION_STATUS_PACKAGE AS
  TYPE T_MIGRATION_STATUS IS RECORD (
  MIGRATION_ID NUMBER,
  MIGRATION_STATUS_ID NUMBER,
  UPLOAD_TIMESTAMP TIMESTAMP
  );

  TYPE T_MIGRATION_STATUS_TABLE IS TABLE OF T_MIGRATION_STATUS;

  FUNCTION GET_MIGRATION_STATUSES(MR_ID IN MIGRATION_REQUESTS.ID%TYPE)
    RETURN T_MIGRATION_STATUS_TABLE PIPELINED;

 PROCEDURE SET_NEW_MIGRATION_STATUS(MR_ID IN MIGRATION_REQUESTS.ID%TYPE, MR_STATUS_STRING IN MIGRATION_STATUSES.STATUS_NAME%TYPE);
END;

CREATE OR REPLACE PACKAGE BODY MIGRATION_STATUS_PACKAGE AS
  FUNCTION GET_MIGRATION_STATUSES(MR_ID IN MIGRATION_REQUESTS.ID%type)
    RETURN T_MIGRATION_STATUS_TABLE PIPELINED AS
    CURSOR MY_CUR IS
      SELECT *
        FROM MIGRATION_STATUS
      WHERE MIGRATION_ID = MR_ID
      ORDER BY MIGRATION_ID;
    BEGIN
      FOR CURR IN MY_CUR
      LOOP
        PIPE ROW (CURR);
      end loop;
    END;

    PROCEDURE SET_NEW_MIGRATION_STATUS(MR_ID IN MIGRATION_REQUESTS.ID%TYPE, MR_STATUS_STRING IN MIGRATION_STATUSES.STATUS_NAME%TYPE) AS
      MR_STATUS_ID NUMBER;
    BEGIN
      SELECT ID INTO MR_STATUS_ID FROM MIGRATION_STATUSES WHERE STATUS_NAME = MR_STATUS_STRING;
      INSERT INTO MIGRATION_STATUS (MIGRATION_ID, MIGRATION_STATUS_ID) VALUES (MR_ID, MR_STATUS_ID);
      COMMIT WORK;
    END;
END MIGRATION_STATUS_PACKAGE;

CREATE OR REPLACE PACKAGE USER_PACKAGE AS
  TYPE T_USER IS RECORD (
  NAME VARCHAR2(30 CHAR),
  EMAIL VARCHAR2(30 CHAR),
  PASSWORD VARCHAR2(30 CHAR)
  );

  TYPE T_USER_TABLE IS TABLE OF T_USER;

  FUNCTION LOG_IN(USER_EMAIL IN USERS.EMAIL%TYPE, USER_PASSWORD IN USERS.PASSWORD%TYPE)
    RETURN T_USER_TABLE PIPELINED;

  PROCEDURE REGISTER(USER_EMAIL IN USERS.EMAIL%TYPE, USER_PASSWORD IN USERS.PASSWORD%TYPE, USER_NAME IN USERS.NAME%TYPE);
END;

CREATE OR REPLACE PACKAGE BODY USER_PACKAGE AS
  FUNCTION LOG_IN(USER_EMAIL IN USERS.EMAIL%TYPE, USER_PASSWORD IN USERS.PASSWORD%TYPE)
    RETURN T_USER_TABLE PIPELINED AS
    CURSOR MY_CUR IS
      SELECT *
      FROM USERS
      WHERE USERS.EMAIL = USER_EMAIL AND USERS.PASSWORD = USER_PASSWORD;
    BEGIN
      FOR rec IN MY_CUR
      LOOP
        pipe row (rec);
      end loop;
    END;

  PROCEDURE REGISTER(USER_EMAIL IN USERS.EMAIL%TYPE, USER_PASSWORD IN USERS.PASSWORD%TYPE, USER_NAME IN USERS.NAME%TYPE) AS
    BEGIN
      INSERT INTO USERS (NAME, PASSWORD, EMAIL) VALUES (USER_NAME, USER_PASSWORD, USER_EMAIL);
      COMMIT WORK;
    END;

END;
