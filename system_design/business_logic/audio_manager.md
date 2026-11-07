# Audio Records Management

## 1. Input (ข้อมูลนำเข้า)
- Audio ID
- Job ID
- Analysis Result จาก Audio Analysis Processing
- User ID / Session ID
- ประเภทคำขอ (ดูผลวิเคราะห์ / ดูประวัติ / ลบข้อมูล)

## 2. Rule (เงื่อนไข)
- ผู้ใช้ต้องผ่านการยืนยันตัวตน
- ผลวิเคราะห์ต้องมาจาก Audio Analysis Processing
- Audio ID และ Job ID ต้องตรงกับข้อมูลในระบบ
- ผู้ใช้เข้าถึงได้เฉพาะผลวิเคราะห์ของตนเอง
- บันทึกผลวิเคราะห์ได้เมื่อประมวลผลสำเร็จเท่านั้น

## 3. Process (กระบวนการ)
- รับผลการวิเคราะห์จาก Audio Analysis Processing
- ตรวจสอบความสัมพันธ์ระหว่าง Audio ID และ Job ID
- บันทึก Score
- บันทึก Feedback
- บันทึก Anomalies ทั้งหมด
- บันทึกสถานะและข้อมูลที่เกี่ยวข้อง
- ส่งข้อมูลให้ระบบเรียกดูประวัติและ Dashboard

## 4. Output (ข้อมูลส่งออก)

**กรณีสำเร็จ**
- Audio Record
- Analysis Result
- Score
- Feedback
- Anomaly Details
- ประวัติการวิเคราะห์

**กรณีผิดพลาด**
- Error Code
- Error Message
- สถานะ: `Failed`