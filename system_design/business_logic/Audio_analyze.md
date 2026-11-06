# Audio Analysis Processing

## 1. Input (ข้อมูลนำเข้า)
- ไฟล์เสียงจาก Audio Upload Management API
- Audio ID
- User ID / Session ID

## 2. Rule (เงื่อนไข)
- ผู้ใช้ต้องผ่านการยืนยันตัวตน
- ไฟล์เสียงต้องอัปโหลดสำเร็จแล้ว
- ไฟล์เสียงต้องอยู่ในรูปแบบที่ AI Service รองรับ
- ผู้ใช้ต้องเป็นเจ้าของไฟล์เสียง
- ไม่อนุญาตให้สร้างงานวิเคราะห์ซ้ำในขณะที่มีงานเดิมกำลังประมวลผล

## 3. Process (กระบวนการ)
1. รับไฟล์เสียงและ Audio ID จาก Audio Upload Management API
2. ตรวจสอบ Session และความเป็นเจ้าของไฟล์
3. สร้างงานวิเคราะห์ (Analysis Job) และกำหนด Job ID
4. กำหนดสถานะเริ่มต้นเป็น `Pending`
5. ส่งไฟล์เสียงไปยัง AI Service เพื่อวิเคราะห์
6. เปลี่ยนสถานะเป็น `Processing`
7. รับและตรวจสอบผลการวิเคราะห์จาก AI Service
8. ส่งผลการวิเคราะห์ไปยัง Audio Records Management เพื่อจัดเก็บ
9. เปลี่ยนสถานะเป็น `Completed`

## 4. Output (ข้อมูลส่งออก)

**กรณีสำเร็จ**
- Job ID
- Audio ID
- ผลการวิเคราะห์ (Analysis Result)
- สถานะ: `Completed`

**กรณีกำลังประมวลผล**
- Job ID
- สถานะ: `Pending` หรือ `Processing`

**กรณีผิดพลาด**
- Job ID (ถ้ามี)
- Error Code
- Error Message
- สถานะ: `Failed`