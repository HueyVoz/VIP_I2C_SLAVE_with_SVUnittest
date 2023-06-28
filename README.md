
# PROJECT: DESIGN UVM I2C-SLAVE VERIFICATION IP  
#


#
 Mục tiêu của luận án này là thiết kế VIP để xác minh đúng  đắn các chức năng có trong  IP I2C_slave. Và kiểm tra tính chính xác funtion của VIP. 
## 1.SVUnit
SVUnit là một khung thử nghiệm mã nguồn mở dành cho các nhà phát triển ASIC và FPGA viết mã Verilog/SystemVerilog. SVUnit tự động, nhanh, nhẹ và dễ sử dụng khiến nó trở thành bài kiểm tra SystemVerilog duy nhất framework hiện có phù hợp với cả kỹ sư thiết kế và xác minh mong muốn mã chất lượng cao và tỷ lệ lỗi thấp.
## 2.Hướng dẫn sử dụng SVUnit
```shell
http://agilesoc.com/open-source-projects/svunit/svunit-user-guide/
```
Hoặc click [here](http://agilesoc.com/open-source-projects/svunit/svunit-user-guide/) để xem hướng dẫn.

## 3.Hướng dẫn khởi chạy dự án
#### Bước 1: Cài đặt biến môi trường `SVUNIT_INSTALL` và `PATH` 
Ở folder `../DESIGN_UVM_I2C_SLAVE_VIP/02.Src` 
Nếu bạn sử dụng bash shell thực hiện lệnh như sau:
```shell
source Setup.bsh
```
Nếu bạn sử dụng csh shell thực hiện lệnh như sau:
```shell
source Setup.csh
```
#### Bước 2: Khởi chạy SVUnit test
```shell
runSVUnit -uvm -s <simulator> # simulator is ius, questa, modelsim, riviera or vcs
```
#### Bước 3: Hiển thị dạng sóng 
```shell
vsim -do run.tcl
```
## 4.Cấu trúc thư mục
```
DESIGN_UVM_I2C_SLAVE_VIP
                    │   
                    ├───00.Docs
                    ├───01.Ref
                    ├───02.Src
                    ├───03.Fra
                    ├───README.md
                    └───READE.html
```
## 5.Tác giả 
    Võ Nguyễn Quang Huy         106190112               19DTCLC3
    Nguyễn Thành Trung          106190135               19DTCLC3
   
## 6.Liên hệ:
   - Gmail: Huyvng0905@gmail.com
   - Phone/zalo: +84935943545
   - Linkedin: https://www.linkedin.com/in/vo-nguyen-quang-huy-09709024a/

 

