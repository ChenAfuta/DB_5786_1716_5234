import random
from datetime import date, timedelta

random.seed(42)


def random_date(start_date: date, end_date: date) -> date:
    delta_days = (end_date - start_date).days
    return start_date + timedelta(days=random.randint(0, delta_days))


def generate_mobile_phone(prefix_digit: int, index: int) -> str:
    """
    Returns a legal Israeli-style mobile number with 10 digits.
    Example: 0500000001
    """
    suffix = f"{index:07d}"
    return f"05{prefix_digit}{suffix}"


def generate_landline_phone(index: int) -> str:
    """
    Returns a legal phone value for the INSURANCE table.
    Matches the regex: ^[0-9\\-+ ]{7,15}$
    Example: 03-1000001
    """
    return f"03-{1000000 + index}"


start_birth = date(1960, 1, 1)
end_birth = date(2010, 12, 31)

start_admission = date(2024, 1, 1)
end_admission = date(2026, 3, 1)

end_payment = date(2026, 3, 20)

departments = [
    "Cardiology",
    "Orthopedics",
    "Neurology",
    "Pediatrics",
    "Oncology",
    "Dermatology",
    "Internal Medicine"
]

coverage_types = ["Basic", "Partial", "Full"]

roles = [
    "Billing Clerk",
    "Billing Manager",
    "Insurance Coordinator",
    "Cashier"
]

payment_methods = [
    "Cash",
    "Credit Card",
    "Bank Transfer",
    "Insurance",
    "Other"
]

claim_statuses = [
    "Pending",
    "Approved",
    "Rejected",
    "Partially Approved"
]

services = [
    "Blood Test",
    "MRI Scan",
    "X-Ray",
    "Consultation",
    "Hospital Stay",
    "ECG",
    "Ultrasound",
    "CT Scan",
    "Physical Examination",
    "Medication Charge"
]


with open("insertTables.sql", "w", encoding="utf-8") as f:
    f.write("-- ==========================================\n")
    f.write("-- insertTables.sql\n")
    f.write("-- Auto-generated sample data for Billing & Finance Division\n")
    f.write("-- ==========================================\n\n")

    # ==========================================
    # 4. BILLING_STAFF - 500 rows
    # ==========================================
    f.write("-- ==========================================\n")
    f.write("-- BILLING_STAFF\n")
    f.write("-- ==========================================\n")
    for i in range(1, 501):
        role = random.choice(roles)

        f.write(
            f"INSERT INTO BILLING_STAFF (billing_staff_id, staff_id, role) "
            f"VALUES ({i}, {i}, '{role}');\n"
        )
    f.write("\n")

    # ==========================================
    # 6. INVOICE - 500 rows
    # ==========================================
    f.write("-- ==========================================\n")
    f.write("-- INVOICE\n")
    f.write("-- ==========================================\n")
    for i in range(1, 501):
        patient_id = i
        admission_id = i
        invoice_date = random_date(start_admission, end_payment)
        total_amount = f"{random.uniform(500.0, 10000.0):.2f}"

        f.write(
            f"INSERT INTO INVOICE (invoice_id, patient_id, admission_id, invoice_date, total_amount) "
            f"VALUES ({i}, {patient_id}, {admission_id}, '{invoice_date}', {total_amount});\n"
        )
    f.write("\n")

    # ==========================================
    # 7. INVOICE_ITEM - 20,000 rows
    # ==========================================
    f.write("-- ==========================================\n")
    f.write("-- INVOICE_ITEM\n")
    f.write("-- ==========================================\n")
    for i in range(1, 20001):
        invoice_id = random.randint(1, 500)
        service_name = random.choice(services)
        cost = f"{random.uniform(50.0, 2000.0):.2f}"

        f.write(
            f"INSERT INTO INVOICE_ITEM (item_id, invoice_id, service_name, cost) "
            f"VALUES ({i}, {invoice_id}, '{service_name}', {cost});\n"
        )
    f.write("\n")

    # ==========================================
    # 8. PAYMENT - 20,000 rows
    # ==========================================
    f.write("-- ==========================================\n")
    f.write("-- PAYMENT\n")
    f.write("-- ==========================================\n")
    for i in range(1, 20001):
        invoice_id = random.randint(1, 500)
        payment_date = random_date(start_admission, end_payment)
        amount = f"{random.uniform(50.0, 5000.0):.2f}"
        payment_method = random.choice(payment_methods)

        f.write(
            f"INSERT INTO PAYMENT (payment_id, invoice_id, payment_date, amount, payment_method) "
            f"VALUES ({i}, {invoice_id}, '{payment_date}', {amount}, '{payment_method}');\n"
        )
    f.write("\n")

    # ==========================================
    # 9. REFUND - 500 rows
    # ==========================================
    f.write("-- ==========================================\n")
    f.write("-- REFUND\n")
    f.write("-- ==========================================\n")
    used_payments = random.sample(range(1, 20001), 500)

    for i, payment_id in enumerate(used_payments, start=1):
        refund_date = random_date(start_admission, end_payment)
        refund_amount = f"{random.uniform(10.0, 500.0):.2f}"

        f.write(
            f"INSERT INTO REFUND (refund_id, payment_id, refund_date, amount) "
            f"VALUES ({i}, {payment_id}, '{refund_date}', {refund_amount});\n"
        )
    f.write("\n")

    # ==========================================
    # 10. INSURANCE_CLAIM - 500 rows
    # ==========================================
    f.write("-- ==========================================\n")
    f.write("-- INSURANCE_CLAIM\n")
    f.write("-- ==========================================\n")
    for i in range(1, 501):
        invoice_id = i
        insurance_id = random.randint(1, 500)
        claim_status = random.choice(claim_statuses)

        f.write(
            f"INSERT INTO INSURANCE_CLAIM (claim_id, invoice_id, insurance_id, claim_status) "
            f"VALUES ({i}, {invoice_id}, {insurance_id}, '{claim_status}');\n"
        )

print("insertTables.sql generated successfully.")