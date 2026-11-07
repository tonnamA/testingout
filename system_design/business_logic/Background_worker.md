## Backgroud worker 

## 1. Input
- job_id : ID ของงานประมวลผล
- audio_id : ID ของไฟล์เสียงที่ต้องการวิเคราะห์
- user_id : ID ของเจ้าของไฟล์เสียง
- file_path : ตำแหน่งไฟล์เสียงใน Storage

## 2. Rule
- job_id : ID ของงานประมวลผล
- audio_id : ID ของไฟล์เสียงที่ต้องการวิเคราะห์
- user_id : ID ของเจ้าของไฟล์เสียง
- file_path : ตำแหน่งไฟล์เสียงใน Storage

## 3. Process
- ค้นหา Analysis Job ที่มีสถานะ Pending
- จอง Job เพื่อป้องกัน Worker อื่นหยิบงานเดียวกัน
- เปลี่ยนสถานะ Job เป็น Processing
- เรียก Storage_Manager เพื่อค้นหาและโหลดไฟล์เสียงจาก audio_id
- ส่งไฟล์เสียงให้ Audio_Analyze
- Audio_Analyze เรียก Algorithm เพื่อประมวลผลเสียง
- รับผลคะแนนและ Feedback จาก Algorithm
- ส่งผลลัพธ์ให้ Audio_Manager บันทึกลง Database
- ตรวจสอบว่าบันทึกผลสำเร็จ แล้วเปลี่ยนสถานะ Job เป็น Completed
- หากเกิดข้อผิดพลาด ให้บันทึก Error และเปลี่ยนสถานะเป็น Failed

## 4. Output
- job_id
- status : Pending, Processing, Completed, Failed
- audio_id
- result_id (เมื่อประมวลผลสำเร็จ)
- error_message (เมื่อเกิดข้อผิดพลาด)