# DB_5786_1716_5234
# Hospital Management System – Billing & Finance Division

## Submitted by:
Hallel Ochana
Chen Afuta

## System:
Hospital Management System

## Selected Unit:
Billing & Finance Division

## Table of Contents
1. Introduction
2. System Screens (AI Generated)
3. ERD Diagram
4. DSD Diagram
5. Design Decisions
6. Data Insertion Methods
7. Backup and Restore

## Introduction
The system is designed to manage hospital billing and financial operations.

It stores data related to invoices, payments, refunds, insurance claims, and billing staff.

The main functionalities include:
- Creating and managing invoices
- Tracking invoice items and services
- Recording payments and refunds
- Managing insurance claims
- Assigning billing staff roles

## System Screens (AI Generated)
https://ai.studio/apps/ff1c6d46-d62f-40b6-a2b2-a5877b81b10b
### Invoice Management

![Invoice](stage_1\SystemSpecification\screen1.png)

### Invoice Details
![Invoice Details](stage_1\SystemSpecification\screen2.jpeg)

### Payments and Refunds
![Payments](stage_1\SystemSpecification\screen4.jpeg)

### Insurance Claims and Billing Staff
![Claims](stage_1\SystemSpecification\screen3.jpeg)

## ERD Diagram
![ERD](stage_1/Diagrams/ERD.png)

## DSD Diagram
![DSD](stage_1/Diagrams/DSD.png)

## Design Decisions

- The Invoice table is separated from Invoice_Item to support multiple services per invoice.
- Payments and Refunds are separated to allow tracking financial transactions accurately.
- Insurance claims are linked to invoices to manage coverage.
- Billing staff roles are stored separately for flexibility and normalization.

## Data Insertion Methods

Three methods were used to insert data:

1. Manual SQL INSERT statements
![Insert SQL](images/insert.png)

2.Programming
![Program](images/generate.png)

3. Data Import Files
![Data Import Files](images/CSV.png)

## Backup and Restore

![Backup and Restore](backupRestore.png)







# שלב ב – תשאול בסיס הנתונים (SQL Queries)

---

## מבוא

בשלב זה ביצענו תשאול של בסיס הנתונים באמצעות שאילתות `SQL`.  
השתמשנו בשאילתות מסוג `SELECT`, `UPDATE`, `DELETE`, וכן הדגמנו שימוש ב־`Transactions` (`ROLLBACK`, `COMMIT`), הוספנו אילוצים (`Constraints`) ואינדקסים (`Indexes`), ובדקנו את השפעתם על ביצועי המערכת.

---

# 1. שאילתות SELECT עם השוואה

## שאילתה 1 – תשלומים עם פרטי חשבונית

### תיאור
השאילתה מציגה תשלומים יחד עם פרטי החשבונית שלהם.

### שאילתה 1A (`JOIN`)

```sql
SELECT 
    p.payment_id,
    p.payment_date,
    p.amount,
    p.payment_method,
    i.invoice_id,
    i.invoice_date,
    i.total_amount
FROM payment p
JOIN invoice i ON p.invoice_id = i.invoice_id;
```

### שאילתה 1B (`Subquery`)

```sql
SELECT
    p.payment_id,
    p.payment_date,
    p.amount,
    p.payment_method,
    p.invoice_id,
    (SELECT i.invoice_date FROM invoice i WHERE i.invoice_id = p.invoice_id),
    (SELECT i.total_amount FROM invoice i WHERE i.invoice_id = p.invoice_id)
FROM payment p;
```

### הרצה ותוצאה

![SQL](images/1A.png)

![SQL](images/1B.png)

### הסבר הבדל
השימוש ב־`JOIN` מאפשר חיבור ישיר ויעיל יותר בין הטבלאות.  
לעומת זאת, `Subquery` מבוצעת עבור כל שורה ולכן פחות יעילה.

---

## שאילתה 2 – החזרים עם פרטי תשלום מקורי

### תיאור
השאילתה מציגה החזרים כספיים יחד עם פרטי התשלום המקורי שבוצע במערכת.

### שאילתה 2A (`JOIN`)

```sql
SELECT
    r.refund_id,
    r.refund_date,
    r.amount AS refund_amount,
    r.refund_reason,
    p.payment_id,
    p.payment_date,
    p.amount AS original_payment_amount,
    p.payment_method
FROM refund r
JOIN payment p
    ON r.payment_id = p.payment_id
ORDER BY r.refund_date DESC
LIMIT 5;
```

### שאילתה 2B (`Subquery`)

```sql
SELECT
    r.refund_id,
    r.refund_date,
    r.amount AS refund_amount,
    r.refund_reason,
    r.payment_id,
    (
        SELECT p.payment_date
        FROM payment p
        WHERE p.payment_id = r.payment_id
    ) AS payment_date,
    (
        SELECT p.amount
        FROM payment p
        WHERE p.payment_id = r.payment_id
    ) AS original_payment_amount,
    (
        SELECT p.payment_method
        FROM payment p
        WHERE p.payment_id = r.payment_id
    ) AS payment_method
FROM refund r
ORDER BY r.refund_date DESC
LIMIT 5;
```

### הרצה ותוצאה

![SQL](images/2A.png)

![SQL](images/2B.png)

### הסבר הבדל
השימוש ב־`JOIN` יעיל יותר כי החיבור בין הטבלאות מתבצע באופן ישיר.  
ב־`Subquery`, מתבצע חיפוש נוסף עבור כל שורה ולכן הביצועים פחות טובים.

---

## שאילתה 3 – הכנסות חודשיות

### שאילתה 3A (`EXTRACT`)

```sql
SELECT
    EXTRACT(YEAR FROM payment_date) AS year,
    EXTRACT(MONTH FROM payment_date) AS month,
    SUM(amount)
FROM payment
GROUP BY year, month;
```

### שאילתה 3B (`DATE_TRUNC`)

```sql
SELECT
    DATE_TRUNC('month', payment_date) AS month,
    SUM(amount)
FROM payment
GROUP BY DATE_TRUNC('month', payment_date);
```

### הרצה ותוצאה

![SQL](images/3A.png)

![SQL](images/3B.png)

### הסבר הבדל
`EXTRACT` מפרק את התאריך לשנה וחודש בנפרד.  
`DATE_TRUNC` מקבץ את הנתונים לפי חודש מלא ולכן מתאים יותר לדוחות וגרפים.

---

## שאילתה 4 – פילוח שיטות תשלום

### שאילתה 4A

```sql
SELECT payment_method, COUNT(*)
FROM payment
GROUP BY payment_method;
```

### שאילתה 4B

```sql
SELECT *
FROM (
    SELECT payment_method, COUNT(*) AS total_payments
    FROM payment
    GROUP BY payment_method
) AS payment_summary;
```

### הרצה ותוצאה

![SQL](images/query4A.png)

![SQL](images/query4B.png)

### הסבר הבדל
שתי השאילתות מחזירות את אותה תוצאה.  
הצורה הראשונה פשוטה וישירה יותר, והצורה השנייה משתמשת בטבלה נגזרת.

---

# 2. שאילתות SELECT נוספות

## שאילתה 5 – החזרים חודשיים

```sql
SELECT
    EXTRACT(MONTH FROM refund_date),
    SUM(amount)
FROM refund
GROUP BY EXTRACT(MONTH FROM refund_date);
```

![SQL](images/5.png)

---

## שאילתה 6 – חשבוניות מעל הממוצע

```sql
SELECT *
FROM invoice
WHERE total_amount > (SELECT AVG(total_amount) FROM invoice);
```

![SQL](images/6.png)

---

## שאילתה 7 – פריטי חשבוניות

```sql
SELECT *
FROM invoice_item;
```

![SQL](images/7.png)

---

## שאילתה 8 – צוות גבייה

```sql
SELECT *
FROM billing_staff;
```

![SQL](images/8.png)

---

# 3. שאילתות UPDATE

## עדכון 1 – עדכון שיטת תשלום

```sql
UPDATE payment
SET payment_method = 'Cash'
WHERE payment_id = 1;
```

### לפני ואחרי

![SQL](images/update_1.png)



---

## עדכון 2 – עדכון תפקיד עובד

```sql
UPDATE billing_staff
SET role = 'Cashier'
WHERE billing_staff_id = 1;
```

### לפני ואחרי

![SQL](images/update_2.png)


---

## עדכון 3 – עדכון שיטת תשלום נוספת

```sql
UPDATE payment
SET payment_method = 'Bank Transfer'
WHERE payment_id = 2;
```

### לפני ואחרי

![SQL](images/update_3.png)



---

# 4. שאילתות DELETE

## מחיקה 1 – מחיקת החזר

```sql
DELETE FROM refund
WHERE refund_id = 1;
```

### לפני ואחרי

![SQL](images/delete_1.png)



---

## מחיקה 2 – מחיקת תשלום

```sql
DELETE FROM payment
WHERE payment_id = 2;
```

### לפני ואחרי

![SQL](images/delete_2.png)



---

## מחיקה 3 – מחיקת עובד מצוות הגבייה

```sql
DELETE FROM billing_staff
WHERE billing_staff_id = 3;
```

### לפני ואחרי

![SQL](images/delete_3.png)



---

# 5. Transactions

## ROLLBACK

### הסבר
פקודת `ROLLBACK` מבטלת את השינויים שבוצעו ומחזירה את בסיס הנתונים למצבו הקודם.

![SQL](images/ROLLBACK.png)

---

## COMMIT

### הסבר
פקודת `COMMIT` שומרת את השינויים לצמיתות במסד הנתונים.

![SQL](images/COMMIT.png)

---

# 6. אילוצים (`Constraints`)

## אילוץ 1 – סיבת החזר לא ריקה

```sql
ALTER TABLE refund
ADD CONSTRAINT chk_refund_reason_not_empty
CHECK (TRIM(refund_reason) <> '');
```

### בדיקת שגיאה

![SQL](images/constraint1.png)

---

## אילוץ 2 – תאריך חשבונית לא עתידי

```sql
ALTER TABLE invoice
ADD CONSTRAINT chk_invoice_date_not_future
CHECK (invoice_date <= CURRENT_DATE);
```

### בדיקת האילוץ
INSERT INTO refund (refund_id, payment_id, refund_date, amount, refund_reason)
VALUES (999999, 2, CURRENT_DATE, 100.00, '');

### תוצאה
![SQL](images/constraint1.png)

---

## אילוץ 3 – תאריך תביעה לא עתידי

```sql
ALTER TABLE insurance_claim
ADD CONSTRAINT chk_claim_date_not_future
CHECK (claim_date <= CURRENT_DATE);
```

### בדיקת שגיאה

![SQL](images/constraint1.png)

---

# 7. אינדקסים (`Indexes`)

## אינדקס 1 – `payment_date`

```sql
CREATE INDEX idx_payment_payment_date
ON payment(payment_date);
```

### לפני ואחרי

![SQL](images/index1_before.png)

![SQL](images/index1_after.png)

---

## אינדקס 2 – `invoice_id`

```sql
CREATE INDEX idx_payment_invoice_id
ON payment(invoice_id);
```

### לפני ואחרי

![SQL](images/index2_before.png)

![SQL](images/index2_after.png)

---

## אינדקס 3 – `payment_id`

```sql
CREATE INDEX idx_refund_payment_id
ON refund(payment_id);
```

### לפני ואחרי

![SQL](images/index3_before.png)

![SQL](images/index3_after.png)

---

# 8. הסבר על אילוצים ואינדקסים

## אילוצים
האילוצים נועדו לשמור על תקינות הנתונים ולמנוע הכנסת נתונים שגויים למסד הנתונים.

## אינדקסים
האינדקסים נועדו לשפר את זמני הריצה של שאילתות, בעיקר כאשר משתמשים ב־`WHERE`, `JOIN`, או מיון לפי שדות נפוצים.



# דוח הפרויקט – שלב ג: אינטגרציה ומבטים

## 1. הקדמה

בשלב זה ביצענו אינטגרציה בין מערכת Billing & Finance המקורית שלנו לבין מערכת נוספת לניהול עובדים, מחלקות, תפקידים ומשמרות בשם Staff Management.

מטרת האינטגרציה הייתה ליצור בסיס נתונים משולב המאפשר חיבור בין מידע פיננסי לבין מידע ארגוני ותפעולי של עובדים בבית החולים.

האינטגרציה בוצעה לפי שיטה א', כלומר אינטגרציה ברמת התכנון והסכמה הלוגית, תוך שימוש בטבלאות הקיימות ושינוי בסיס הנתונים באמצעות פקודות SQL.

---

# 2. תרשימי DSD ו־ERD

בשלב הראשון קיבלנו גיבוי של מערכת Staff Management.

לאחר שחזור בסיס הנתונים ניתחנו את הטבלאות, המפתחות הראשיים והמפתחות הזרים, ומתוכם יצרנו:

- DSD של האגף החדש
- ERD של האגף החדש
- ERD משותף לאחר אינטגרציה
- DSD לאחר אינטגרציה

## 2.1 DSD של האגף החדש

![DSD של האגף החדש](stage_3/erdplus(5).png)

## 2.2 ERD של האגף החדש

![ERD של האגף החדש](stage_3/erdplus(6).png)

## 2.3 ERD משותף לאחר אינטגרציה

![ERD משותף לאחר אינטגרציה](stage_3/erdplus(7).png)

## 2.4 DSD לאחר אינטגרציה

![DSD לאחר אינטגרציה](stage_3/erdplus(8).png)
---

# 3. אלגוריתם Reverse Engineering

כדי ליצור ERD מתוך בסיס הנתונים שהתקבל, ביצענו תהליך של Reverse Engineering.

השלבים שבוצעו:

1. זיהוי כל הטבלאות בבסיס הנתונים.
2. זיהוי המפתחות הראשיים והמפתחות הזרים.
3. כל טבלה עצמאית הוגדרה כישות ב־ERD.
4. עמודות רגילות הוגדרו כמאפיינים של הישויות.
5. מפתחות זרים הומרו לקשרים בין ישויות.
6. טבלאות בעלות מאפיינים עצמאיים בנוסף למפתחות זרים הוגדרו כישויות מקשרות.
7. לאחר זיהוי כל הישויות והקשרים נבנה ERD חדש של המערכת שהתקבלה.

---

# 4. החלטות שנעשו בשלב האינטגרציה

במהלך האינטגרציה זיהינו חפיפה בין הישויות:

- Billing_Staff
- Staff

שתי הישויות מייצגות עובדים במערכת, ולכן החלטנו לאחד אותן לישות אחת בשם `Staff`.

בנוסף:

- הוספנו קשר בין `Invoice` לבין `Staff`.
- שמרנו את טבלאות החיוב המקוריות:
  - Invoice
  - Payment
  - Refund
  - Insurance_Claim
  - Invoice_Item

- שמרנו את טבלאות מערכת העובדים:
  - Staff
  - Departments
  - Roles
  - Shifts
  - ShiftAssignments
  - Salaries

האינטגרציה אפשרה יצירת מערכת אחת המשלבת מידע פיננסי עם מידע על עובדים ומחלקות.

---

# 5. הסבר מילולי של התהליך והפקודות

לאחר יצירת ה־ERD המשותף וה־DSD לאחר אינטגרציה, עברנו למימוש בבסיס הנתונים.

בקובץ `Integrate.sql` ביצענו התאמות לבסיס הנתונים הקיים באמצעות:

```sql
ALTER TABLE
להוספת עמודות חדשות.

ADD COLUMN

להוספת שדות כגון handled_by_staffid.

ADD CONSTRAINT

להוספת אילוצים וקשרים חדשים.

FOREIGN KEY

ליצירת קשרים בין טבלאות.

האינטגרציה בוצעה ללא מחיקה של הטבלאות הקיימות וללא יצירה מחדש של בסיס הנתונים.

6. מבטים

בשלב זה יצרנו שני מבטים, כאשר כל מבט מייצג נקודת מבט שונה על בסיס הנתונים המשולב.

6.1 מבט ראשון – חיובים, תשלומים והחזרים

שם המבט:

v_billing_invoice_payments
תיאור המבט

מבט זה מייצג את נקודת המבט של מערכת Billing & Finance.

המבט מציג מידע על:

חשבוניות
תשלומים
החזרים

המבט מחבר בין הטבלאות:

Invoice
Payment
Refund

באמצעות LEFT JOIN.

המבט מאפשר לראות עבור כל חשבונית:

מספר חשבונית
מזהה מטופל
מזהה אשפוז
תאריך חשבונית
סכום החשבונית
פרטי תשלומים
פרטי החזרים
קוד יצירת המבט
CREATE OR REPLACE VIEW v_billing_invoice_payments AS
SELECT
    i.invoice_id,
    i.patient_id,
    i.admission_id,
    i.invoice_date,
    i.total_amount AS invoice_total,
    p.payment_id,
    p.payment_date,
    p.amount AS payment_amount,
    p.payment_method,
    r.refund_id,
    r.refund_date,
    r.amount AS refund_amount
FROM invoice i
LEFT JOIN payment p
    ON i.invoice_id = p.invoice_id
LEFT JOIN refund r
    ON p.payment_id = r.payment_id;
שליפת נתונים מהמבט
SELECT *
FROM v_billing_invoice_payments
LIMIT 10;
פלט:
invoice_id	patient_id	admission_id	invoice_date	invoice_total	payment_id	payment_date	payment_amount	payment_method	refund_id	refund_date	refund_amount
1	101	3001	2026-01-02	450.00	1	2026-01-03	450.00	Credit Card	NULL	NULL	NULL
2	102	3002	2026-01-04	700.00	2	2026-01-05	700.00	Cash	1	2026-01-06	100.00
3	103	3003	2026-01-06	250.00	3	2026-01-06	250.00	Bank Transfer	NULL	NULL	NULL
4	104	3004	2026-01-08	980.00	4	2026-01-09	980.00	Credit Card	2	2026-01-10	200.00
6.2 שאילתה ראשונה על המבט הראשון – סכום ששולם עבור כל חשבונית
תיאור השאילתה

שאילתה זו מחשבת את סכום התשלומים הכולל עבור כל חשבונית.

המטרה היא לבדוק כמה כסף שולם בפועל עבור כל חשבונית.

קוד השאילתה
SELECT
    invoice_id,
    invoice_total,
    COALESCE(SUM(payment_amount), 0) AS total_paid
FROM v_billing_invoice_payments
GROUP BY invoice_id, invoice_total
ORDER BY invoice_id;
פלט:
invoice_id	invoice_total	total_paid
1	450.00	450.00
2	700.00	700.00
3	250.00	250.00
4	980.00	980.00
6.3 שאילתה שנייה על המבט הראשון – חשבוניות עם החזרים
תיאור השאילתה

שאילתה זו מציגה את כל החשבוניות שבוצע עבורן החזר כספי.

קוד השאילתה
SELECT
    invoice_id,
    payment_id,
    refund_id,
    refund_date,
    refund_amount
FROM v_billing_invoice_payments
WHERE refund_id IS NOT NULL
ORDER BY refund_date DESC;
פלט לדוגמה
invoice_id	payment_id	refund_id	refund_date	refund_amount
4	4	2	2026-01-10	200.00
2	2	1	2026-01-06	100.00
7. מבט שני – עובדים, מחלקות ותפקידים

שם המבט:

v_staff_department_roles
תיאור המבט

מבט זה מייצג את נקודת המבט של מערכת Staff Management.

המבט מציג מידע על עובדים, המחלקות שלהם והתפקידים שלהם.

המבט מחבר בין הטבלאות:

Staff
Departments
Roles

באמצעות JOIN.

קוד יצירת המבט
CREATE OR REPLACE VIEW v_staff_department_roles AS
SELECT
    s.staffid,
    s.firstname,
    s.lastname,
    s.email,
    s.status,
    s.hiredate,
    d.deptid,
    d.deptname,
    d.building,
    d.floor,
    ro.roleid,
    ro.rolename,
    ro.basehourlysalary
FROM staff s
JOIN departments d
    ON s.deptid = d.deptid
JOIN roles ro
    ON s.roleid = ro.roleid;
שליפת נתונים מהמבט
SELECT *
FROM v_staff_department_roles
LIMIT 10;

פלט:
staffid	firstname	lastname	email	status	hiredate	deptid	deptname	building	floor	roleid	rolename	basehourlysalary
1	Daniel	Cohen	daniel@hospital.org.il	Active	2024-01-10	1	Finance	A	2	1	Accountant	70.00
2	Noa	Levi	noa@hospital.org.il	Active	2023-07-21	2	Emergency	B	1	2	Shift Manager	85.00
3	Amit	Bar	amit@hospital.org.il	On Leave	2022-05-18	1	Finance	A	2	3	Billing Clerk	55.00
4	Yael	Mizrahi	yael@hospital.org.il	Active	2025-02-01	3	Administration	C	3	4	Department Clerk	50.00
7.1 שאילתה ראשונה על המבט השני – מספר עובדים בכל מחלקה
תיאור השאילתה

שאילתה זו מציגה כמה עובדים קיימים בכל מחלקה.

קוד השאילתה
SELECT
    deptname,
    COUNT(*) AS staff_count
FROM v_staff_department_roles
GROUP BY deptname
ORDER BY staff_count DESC;
פלט לדוגמה
deptname	staff_count
Finance	12
Emergency	8
Administration	5
Pediatrics	4
7.2 שאילתה שנייה על המבט השני – עובדים פעילים והשכר השעתי שלהם
תיאור השאילתה

שאילתה זו מציגה עובדים פעילים בלבד יחד עם התפקיד שלהם והשכר השעתי הבסיסי שלהם.

קוד השאילתה
SELECT
    staffid,
    firstname,
    lastname,
    deptname,
    rolename,
    basehourlysalary
FROM v_staff_department_roles
WHERE status = 'Active'
ORDER BY basehourlysalary DESC;
פלט לדוגמה
staffid	firstname	lastname	deptname	rolename	basehourlysalary
2	Noa	Levi	Emergency	Shift Manager	85.00
1	Daniel	Cohen	Finance	Accountant	70.00
4	Yael	Mizrahi	Administration	Department Clerk	50.00

# 8. סיכום

בשלב זה ביצענו אינטגרציה מלאה בין מערכת Billing & Finance לבין מערכת Staff Management.

במהלך העבודה ביצענו תהליך Reverse Engineering למערכת החדשה, יצרנו DSD ו־ERD, ולאחר מכן שילבנו בין שתי המערכות באמצעות ERD משותף ו־DSD לאחר אינטגרציה.

האינטגרציה אפשרה לחבר בין עולם החיובים והתשלומים לבין עולם העובדים, המחלקות והתפקידים בבית החולים.

בנוסף, ביצענו שינויים בבסיס הנתונים באמצעות קובץ `Integrate.sql`, תוך שימוש בפקודות `ALTER TABLE`, הוספת קשרים חדשים ומפתחות זרים, ללא יצירה מחדש של כל הטבלאות.

בשלב המבטים יצרנו שני מבטים מרכזיים:

1. מבט המציג חשבוניות, תשלומים והחזרים.
2. מבט המציג עובדים, מחלקות ותפקידים.

לכל מבט נכתבו שתי שאילתות משמעותיות הכוללות תיאור מילולי, קוד SQL ופלט לדוגמה.

בסיום שלב זה התקבל בסיס נתונים משולב המאפשר ניהול עובדים, מחלקות, תשלומים, החזרים וחשבוניות במערכת אחת אחידה ומקושרת.
