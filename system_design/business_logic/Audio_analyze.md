# Audio Analysis Processing

## 1. Input (ข้อมูลนำเข้า)
- ไฟล์เสียงจาก Audio File / File Path
- Audio ID
- User ID / Session ID

## Actors & Dependencies
    User
    FastAPI Backend
    Database
    Audio Storage
    Python Algorithm

## 2. Rule (เงื่อนไข)
- ผู้ใช้ต้องผ่านการยืนยันตัวตน
- ไฟล์เสียงต้องอัปโหลดสำเร็จแล้ว
- ไฟล์เสียงต้องอยู่ในรูปแบบที่ Algorithm รองรับ
- ผู้ใช้ต้องเป็นเจ้าของไฟล์เสียง
- ไม่อนุญาตให้สร้างงานวิเคราะห์ซ้ำในขณะที่มีงานเดิมกำลังประมวลผล
- Algorithm ต้องคืนผลลัพธ์ตามรูปแบบที่ Backend กำหนด
- ต้องตรวจสอบความถูกต้องของ Analysis Result ก่อนบันทึก
- ต้องบันทึก Overall Score และ Dimension Scores   
- ต้องบันทึก Anomalies และ Feedback ที่ Algorithm ตรวจพบ
- ต้องรองรับกรณีข้อมูลไม่เพียงพอ (insufficient_data)
- Job จะเป็น Completed หลังบันทึกผลลง Database สำเร็จ

## Data & Access Control
    มี Audio ID, User ID, Audio Storage Path และ Analysis Configuration
    Data	        Source
    Overall Score	W4
    Pitch Score	    W4
    Duration Score	W4
    Pause Score	    W4
    Anomaly Count	W4
    Severity Count	W4
    Feedback List	W4
    Algorithm Version	Backend / Algorithm Configuration
    
## 3. Process (กระบวนการ)
1. รับไฟล์เสียงและ Audio ID จาก Audio Upload Management API
2. ตรวจสอบ Session และความเป็นเจ้าของไฟล์
3. backgroud worker รับ job
  <!--  -->
3. สร้างงานวิเคราะห์ (Analysis Job) และกำหนด Job ID
4. กำหนดสถานะเริ่มต้นเป็น `Pending`
5. ส่งไฟล์เสียงไปยัง AI Service เพื่อวิเคราะห์
6. เปลี่ยนสถานะเป็น `Processing`
7. รับและตรวจสอบผลการวิเคราะห์จาก AI Service
8. ส่งผลการวิเคราะห์ไปยัง Audio Records Management เพื่อจัดเก็บ
9. เปลี่ยนสถานะเป็น `Completed`
<!--  -->

## 4. Output (ข้อมูลส่งออก)

**กรณีสำเร็จ**
- Job ID
- Audio ID
- ผลการวิเคราะห์ (Analysis Result) 
    - ผลการวิเคราะห์มี verall Score
        - Pitch Score
        - Duration Score
        - Pause Score
        - จำนวน Anomalies
        - จำนวน High / Medium / Low
        - Feedback สูงสุด 5 รายการสำหรับแสดงผล
        - All Anomalies สำหรับจัดเก็บรายละเอียดทั้งหมด
- ประเภท feedback ที่ algo ตรวจจับได้ : 
        - PITCH_TOO_HIGH
        - PITCH_TOO_LOW
        - TOO_FAST
        - TOO_SLOW
        - VERSE_PAUSE_MISSING
        - EXTRA_PAUSE
- สถานะ: `Completed`

**กรณีกำลังประมวลผล**
- Job ID
- สถานะ: `Pending` หรือ `Processing`

**กรณีผิดพลาด**
- Job ID (ถ้ามี)
- Error Code
- Error Message
- สถานะ: `Failed`

