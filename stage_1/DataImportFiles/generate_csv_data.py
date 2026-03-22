import csv
import os
import random
from datetime import date, timedelta

random.seed(42)


def random_date(start_date: date, end_date: date) -> date:
    delta_days = (end_date - start_date).days
    return start_date + timedelta(days=random.randint(0, delta_days))


def generate_mobile_phone(prefix_digit: int, index: int) -> str:
    suffix = str(index).zfill(7)
    return f"05{prefix_digit}{suffix}"


def generate_landline_phone(index: int) -> str:
    return f"03-{1000000 + index}"


os.makedirs("csv_data", exist_ok=True)

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

# 4. BILLING_STAFF
with open("csv_data/billing_staff.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["billing_staff_id", "staff_id", "role"])
    for i in range(1, 501):
        writer.writerow([
            i,
            i,
            random.choice(roles)
        ])

# 6. INVOICE
with open("csv_data/invoice.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["invoice_id", "patient_id", "admission_id", "invoice_date", "total_amount"])
    for i in range(1, 501):
        writer.writerow([
            i,
            i,
            i,
            random_date(start_admission, end_payment),
            f"{random.uniform(500, 10000):.2f}"
        ])

# 7. INVOICE_ITEM
with open("csv_data/invoice_item.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["item_id", "invoice_id", "service_name", "cost"])
    for i in range(1, 20001):
        writer.writerow([
            i,
            random.randint(1, 500),
            random.choice(services),
            f"{random.uniform(50, 2000):.2f}"
        ])

# 8. PAYMENT
with open("csv_data/payment.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["payment_id", "invoice_id", "payment_date", "amount", "payment_method"])
    for i in range(1, 20001):
        writer.writerow([
            i,
            random.randint(1, 500),
            random_date(start_admission, end_payment),
            f"{random.uniform(50, 5000):.2f}",
            random.choice(payment_methods)
        ])

# 9. REFUND
used_payments = random.sample(range(1, 20001), 500)
with open("csv_data/refund.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["refund_id", "payment_id", "refund_date", "amount"])
    for i, payment_id in enumerate(used_payments, start=1):
        writer.writerow([
            i,
            payment_id,
            random_date(start_admission, end_payment),
            f"{random.uniform(10, 500):.2f}"
        ])

# 10. INSURANCE_CLAIM
with open("csv_data/insurance_claim.csv", "w", newline="", encoding="utf-8") as f:
    writer = csv.writer(f)
    writer.writerow(["claim_id", "invoice_id", "insurance_id", "claim_status"])
    for i in range(1, 501):
        writer.writerow([
            i,
            i,
            random.randint(1, 500),
            random.choice(claim_statuses)
        ])

print("CSV files generated successfully in the csv_data folder.")