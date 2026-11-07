# Audio Upload Management

## 1. Input (ข้อมูลนำเข้า)
- ไฟล์เสียง (Audio File)
- ข้อมูลผู้ใช้ (User ID / Session ID)
- ข้อมูลไฟล์ (File Metadata)

## 2. Rule (เงื่อนไข)
- ผู้ใช้ต้องผ่านการยืนยันตัวตน
- ต้องได้รับข้อมูล Poem_id จาก frontend request
- รองรับเฉพาะรูปแบบไฟล์เสียงที่ระบบกำหนด (เน้น .wav)
- ขนาดไฟล์ต้องไม่เกินขีดจำกัด
- ผู้ใช้สามารถอัปโหลดไฟล์ได้เฉพาะในสิทธิ์ของตนเอง
- Audio Record ต้องเชื่อมโยงกับเจ้าของไฟล์เสียง
- ต้องตรวจสอบไฟล์ก่อนบันทึกลง Storage

## 3. Process (กระบวนการ)
1. รับไฟล์เสียงจาก Frontend และ Poem ID
2. ตรวจสอบ Session และสิทธิ์ของผู้ใช้
3. ตรวจสอบรูปแบบ ขนาด และข้อมูลของไฟล์
4. อัปโหลดไฟล์ไปยัง Storage
5. บันทึกข้อมูลไฟล์ลง Database
ุ6. สร้าง Job สถานะ Pending
7. ส่ง Audio ID และ Job ID กลับ Frontend

## 4. Output (ข้อมูลส่งออก)

**กรณีสำเร็จ**
- Audio ID
- ตำแหน่งจัดเก็บไฟล์ (Storage Path)
- สถานะ: `Completed`

**กรณีผิดพลาด**
- Error Code
- Error Message
- สถานะ: `Failed`