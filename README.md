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
