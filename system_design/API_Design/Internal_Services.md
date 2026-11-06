# Internal Services

ส่วนประกอบภายใน Backend ที่ทำงานร่วมกัน ไม่ใช่ Public API และ Frontend
ไม่เรียกใช้งานโดยตรง

## Services

  Component                  หน้าที่
  -------------------------- ----------------------------------------
  Auth Management            ตรวจสอบผู้ใช้ จัดการ Login, Session และสิทธิ์
  Audio Upload Management    ตรวจสอบไฟล์ รับไฟล์ และบันทึกลง Storage
  Background Worker          รับ Job และประมวลผลเสียงเบื้องหลัง
  Audio Analyze Processing   เตรียมเสียงและควบคุมขั้นตอนวิเคราะห์
  AI Poetry Algorithm        วิเคราะห์เสียงและคำนวณคะแนน
  Backend Result Handle      ตรวจสอบและจัดรูปแบบผลจาก Algorithm
  Audio Records Management   บันทึกและดึงข้อมูล Audio Record กับผลวิเคราะห์
  Dashboard Management       รวมข้อมูลและส่งข้อมูลให้ Dashboard

## Audio Processing Flow

1.  Audio Upload Management รับไฟล์และตรวจสอบชนิด/ขนาด
2.  บันทึกไฟล์ลง Audio Storage และสร้าง Audio Record กับ Job ใน MySQL
3.  Background Worker รับ Job และเปลี่ยนสถานะเป็น `Processing`
4.  Audio Analyze Processing ดึงไฟล์จาก Storage และเตรียมเสียง
5.  เรียก AI Poetry Algorithm เพื่อวิเคราะห์และคำนวณคะแนน
6.  Backend Result Handle ตรวจสอบผลลัพธ์
7.  Audio Records Management บันทึกผลลง MySQL
8.  เปลี่ยนสถานะ Job เป็น `Completed` เมื่อบันทึกผลสำเร็จ
9.  หากเกิดข้อผิดพลาด ให้เปลี่ยนสถานะเป็น `Failed`

## Data & Access Rules

-   `Storage Path` เป็นข้อมูลภายใน Backend ไม่รับจาก Frontend
-   ใช้ Session เพื่อระบุเจ้าของ Audio Record และ Job
-   เก็บไฟล์ต้นฉบับไว้ใน Audio Storage
-   เก็บ Metadata, Job Status และ Analysis Result ใน MySQL
-   Dashboard Management อ่านข้อมูลของผู้ใช้ปัจจุบันเท่านั้น

## Responsibility Boundary

-   API Layer รับ Request และส่ง Response
-   Service Layer จัดการ Business Logic
-   Worker ทำงานที่ใช้เวลานานโดยไม่บล็อก Request
-   Algorithm ทำหน้าที่วิเคราะห์ ไม่จัดการ HTTP หรือ Session
-   Database และ Storage ใช้จัดเก็บข้อมูลคนละประเภท
