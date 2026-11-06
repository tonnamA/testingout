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
1. รับ Analysis Result และ Job ID จาก Audio Analysis Processing
2. ตรวจสอบสถานะและความถูกต้องของผลวิเคราะห์
3. บันทึกผลวิเคราะห์ลง Database โดยเชื่อมโยงกับ Audio ID และ User ID
4. รับคำขอเรียกดูประวัติหรือผลวิเคราะห์จาก Frontend
5. ตรวจสอบสิทธิ์และดึงข้อมูลจาก Database
6. ลบข้อมูลผลวิเคราะห์เมื่อมีคำขอและผ่านการตรวจสอบสิทธิ์

## 4. Output (ข้อมูลส่งออก)

**กรณีสำเร็จ**
- Audio ID
- Job ID
- Analysis Result
- วันที่ประมวลผล
- สถานะการดำเนินการ

**กรณีผิดพลาด**
- Error Code
- Error Message
- สถานะ: `Failed`