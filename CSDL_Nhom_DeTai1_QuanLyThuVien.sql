/*
  ĐỀ TÀI 1 – QUẢN LÝ THƯ VIỆN
  Script T-SQL minh họa cho báo cáo học phần Cơ sở dữ liệu.
  Dữ liệu dưới đây là dữ liệu tổng hợp, hoàn toàn giả lập.
  Chạy trên SQL Server 2019+ bằng SSMS. Tạo database nếu chưa tồn tại.
*/
IF DB_ID(N'QLThuVien_Nhom') IS NULL
    CREATE DATABASE QLThuVien_Nhom1;
GO
USE QLThuVien_Nhom;
GO

/* Xóa đối tượng theo thứ tự phụ thuộc để có thể chạy lại script */
DROP TRIGGER IF EXISTS dbo.TR_ChiTietMuon_KiemTra;
DROP TRIGGER IF EXISTS dbo.TR_PhieuMuon_KiemTraNgay;
DROP TRIGGER IF EXISTS dbo.TR_BanSach_KhongDoiTinhTrangKhiMuon;
DROP TRIGGER IF EXISTS dbo.TR_ThanhToanPhat_GioiHan;
DROP TRIGGER IF EXISTS dbo.TR_KhoanPhat_KiemTraTien;
DROP TABLE IF EXISTS dbo.THANH_TOAN_PHAT;
DROP TABLE IF EXISTS dbo.KHOAN_PHAT;
DROP TABLE IF EXISTS dbo.CHI_TIET_MUON;
DROP TABLE IF EXISTS dbo.PHIEU_MUON;
DROP TABLE IF EXISTS dbo.BAN_SACH;
DROP TABLE IF EXISTS dbo.DAU_SACH_TAC_GIA;
DROP TABLE IF EXISTS dbo.DAU_SACH;
DROP TABLE IF EXISTS dbo.NHAN_VIEN;
DROP TABLE IF EXISTS dbo.DOC_GIA;
DROP TABLE IF EXISTS dbo.NHA_XUAT_BAN;
DROP TABLE IF EXISTS dbo.THE_LOAI;
DROP TABLE IF EXISTS dbo.TAC_GIA;
GO

CREATE TABLE dbo.THE_LOAI (
    MaTheLoai   CHAR(4)       NOT NULL CONSTRAINT PK_TheLoai PRIMARY KEY,
    TenTheLoai NVARCHAR(80)  NOT NULL CONSTRAINT UQ_TheLoai_Ten UNIQUE,
    MoTa  NVARCHAR(250) NULL
);

CREATE TABLE dbo.NHA_XUAT_BAN (
    MaNhaXuatBan   CHAR(5)       NOT NULL CONSTRAINT PK_NhaXuatBan PRIMARY KEY,
    TenNhaXuatBan NVARCHAR(120) NOT NULL CONSTRAINT UQ_NhaXuatBan_Ten UNIQUE,
    ThanhPho          NVARCHAR(80)  NULL
);

CREATE TABLE dbo.TAC_GIA (
    MaTacGia   CHAR(5)       NOT NULL CONSTRAINT PK_TacGia PRIMARY KEY,
    TenTacGia NVARCHAR(120) NOT NULL,
    QuocGia    NVARCHAR(80)  NOT NULL CONSTRAINT DF_TacGia_QuocGia DEFAULT N'Chưa xác định'
);

CREATE TABLE dbo.DAU_SACH (
    MaDauSach      CHAR(6)       NOT NULL CONSTRAINT PK_DauSach PRIMARY KEY,
    MaTheLoai  CHAR(4)       NOT NULL,
    MaNhaXuatBan CHAR(5)       NOT NULL,
    ISBN        VARCHAR(13)   NOT NULL CONSTRAINT UQ_DauSach_ISBN UNIQUE,
    TieuDe       NVARCHAR(180) NOT NULL,
    NamXuatBan SMALLINT      NOT NULL,
    TrangThaiDauSach  VARCHAR(10)   NOT NULL CONSTRAINT DF_DauSach_TrangThai DEFAULT 'ACTIVE',
    CONSTRAINT FK_DauSach_TheLoai  FOREIGN KEY (MaTheLoai) REFERENCES dbo.THE_LOAI(MaTheLoai),
    CONSTRAINT FK_DauSach_NhaXuatBan FOREIGN KEY (MaNhaXuatBan) REFERENCES dbo.NHA_XUAT_BAN(MaNhaXuatBan),
    CONSTRAINT CK_DauSach_NamXuatBan CHECK (NamXuatBan BETWEEN 1450 AND 2100),
    CONSTRAINT CK_DauSach_TrangThai CHECK (TrangThaiDauSach IN ('ACTIVE','RETIRED'))
);

CREATE TABLE dbo.DAU_SACH_TAC_GIA (
    MaDauSach           CHAR(6)       NOT NULL,
    MaTacGia         CHAR(5)       NOT NULL,
    ThuTuTacGia      SMALLINT      NOT NULL,
    VaiTroDongGop NVARCHAR(40)  NOT NULL CONSTRAINT DF_DauSachTacGia_VaiTro DEFAULT N'Tác giả',
    CONSTRAINT PK_DauSachTacGia PRIMARY KEY (MaDauSach, MaTacGia),
    CONSTRAINT FK_DauSachTacGia_DauSach   FOREIGN KEY (MaDauSach) REFERENCES dbo.DAU_SACH(MaDauSach),
    CONSTRAINT FK_DauSachTacGia_TacGia FOREIGN KEY (MaTacGia) REFERENCES dbo.TAC_GIA(MaTacGia),
    CONSTRAINT UQ_DauSachTacGia_ThuTu UNIQUE (MaDauSach, ThuTuTacGia),
    CONSTRAINT CK_DauSachTacGia_ThuTu CHECK (ThuTuTacGia >= 1)
);

CREATE TABLE dbo.BAN_SACH (
    MaBanSach         CHAR(8)       NOT NULL CONSTRAINT PK_BanSach PRIMARY KEY,
    MaDauSach         CHAR(6)       NOT NULL,
    NgayNhap DATE         NOT NULL,
    TinhTrangBan  VARCHAR(10)   NOT NULL CONSTRAINT DF_BanSach_TinhTrang DEFAULT 'GOOD',
    MaKe      VARCHAR(12)   NOT NULL,
    ChiPhiNhap DECIMAL(10,2) NOT NULL CONSTRAINT DF_BanSach_ChiPhi DEFAULT 0,
    CONSTRAINT FK_BanSach_DauSach FOREIGN KEY (MaDauSach) REFERENCES dbo.DAU_SACH(MaDauSach),
    CONSTRAINT CK_BanSach_TinhTrang CHECK (TinhTrangBan IN ('GOOD','DAMAGED','LOST','REPAIR')),
    CONSTRAINT CK_BanSach_ChiPhi CHECK (ChiPhiNhap >= 0)
);

CREATE TABLE dbo.DOC_GIA (
    MaDocGia   CHAR(6)       NOT NULL CONSTRAINT PK_DocGia PRIMARY KEY,
    HoTen   NVARCHAR(120) NOT NULL,
    NgayThamGia   DATE          NOT NULL CONSTRAINT DF_DocGia_NgayThamGia DEFAULT (CONVERT(date, GETDATE())),
    TrangThaiDocGia VARCHAR(10) NOT NULL CONSTRAINT DF_DocGia_TrangThai DEFAULT 'ACTIVE',
    CONSTRAINT CK_DocGia_TrangThai CHECK (TrangThaiDocGia IN ('ACTIVE','SUSPENDED','CLOSED'))
);

CREATE TABLE dbo.NHAN_VIEN (
    MaNhanVien   CHAR(5)       NOT NULL CONSTRAINT PK_NhanVien PRIMARY KEY,
    TenNhanVien NVARCHAR(120) NOT NULL,
    NgayTuyenDung  DATE          NOT NULL,
    TrangThaiNhanVien VARCHAR(10) NOT NULL CONSTRAINT DF_NhanVien_TrangThai DEFAULT 'ACTIVE',
    CONSTRAINT CK_NhanVien_TrangThai CHECK (TrangThaiNhanVien IN ('ACTIVE','INACTIVE'))
);

CREATE TABLE dbo.PHIEU_MUON (
    MaPhieuMuon       CHAR(6)      NOT NULL CONSTRAINT PK_PhieuMuon PRIMARY KEY,
    MaDocGia     CHAR(6)      NOT NULL,
    MaNhanVien      CHAR(5)      NOT NULL,
    NgayMuon     DATE         NOT NULL CONSTRAINT DF_PhieuMuon_Ngay DEFAULT (CONVERT(date, GETDATE())),
    TrangThaiPhieu VARCHAR(10) NOT NULL CONSTRAINT DF_PhieuMuon_TrangThai DEFAULT 'OPEN',
    CONSTRAINT FK_PhieuMuon_DocGia FOREIGN KEY (MaDocGia) REFERENCES dbo.DOC_GIA(MaDocGia),
    CONSTRAINT FK_PhieuMuon_NhanVien  FOREIGN KEY (MaNhanVien) REFERENCES dbo.NHAN_VIEN(MaNhanVien),
    CONSTRAINT CK_PhieuMuon_TrangThai CHECK (TrangThaiPhieu IN ('OPEN','CLOSED','CANCELLED'))
);

CREATE TABLE dbo.CHI_TIET_MUON (
    MaPhieuMuon        CHAR(6)     NOT NULL,
    MaBanSach        CHAR(8)     NOT NULL,
    HanTra       DATE        NOT NULL,
    NgayTra    DATE        NULL,
    TinhTrangKhiTra VARCHAR(10) NULL,
    CONSTRAINT PK_ChiTietMuon PRIMARY KEY (MaPhieuMuon, MaBanSach),
    CONSTRAINT FK_ChiTietMuon_PhieuMuon FOREIGN KEY (MaPhieuMuon) REFERENCES dbo.PHIEU_MUON(MaPhieuMuon),
    CONSTRAINT FK_ChiTietMuon_BanSach FOREIGN KEY (MaBanSach) REFERENCES dbo.BAN_SACH(MaBanSach),
    CONSTRAINT CK_ChiTietMuon_TinhTrangKhiTra CHECK (TinhTrangKhiTra IS NULL OR TinhTrangKhiTra IN ('GOOD','DAMAGED','LOST')),
    CONSTRAINT CK_ChiTietMuon_CapNgayTinhTrangTra CHECK ((NgayTra IS NULL AND TinhTrangKhiTra IS NULL) OR (NgayTra IS NOT NULL AND TinhTrangKhiTra IS NOT NULL))
);
/* Mỗi bản sách chỉ có tối đa một lượt mượn đang mở tại cùng thời điểm. */
CREATE UNIQUE INDEX UX_ChiTietMuon_MotKhoanMoMoiBan
    ON dbo.CHI_TIET_MUON(MaBanSach) WHERE NgayTra IS NULL;

CREATE TABLE dbo.KHOAN_PHAT (
    MaKhoanPhat      CHAR(6)      NOT NULL CONSTRAINT PK_KhoanPhat PRIMARY KEY,
    MaPhieuMuon      CHAR(6)      NOT NULL,
    MaBanSach      CHAR(8)      NOT NULL,
    NgayLap  DATE         NOT NULL,
    LoaiPhat    VARCHAR(12)  NOT NULL,
    TienPhat  DECIMAL(10,2) NOT NULL,
    TrangThaiPhat  VARCHAR(10)  NOT NULL CONSTRAINT DF_KhoanPhat_TrangThai DEFAULT 'UNPAID',
    GhiChu        NVARCHAR(200) NULL,
    CONSTRAINT FK_KhoanPhat_ChiTietMuon FOREIGN KEY (MaPhieuMuon, MaBanSach) REFERENCES dbo.CHI_TIET_MUON(MaPhieuMuon, MaBanSach),
    CONSTRAINT CK_KhoanPhat_Loai CHECK (LoaiPhat IN ('OVERDUE','DAMAGE','LOSS')),
    CONSTRAINT CK_KhoanPhat_Tien CHECK (TienPhat > 0),
    CONSTRAINT CK_KhoanPhat_TrangThai CHECK (TrangThaiPhat IN ('UNPAID','PARTIAL','PAID'))
);

CREATE TABLE dbo.THANH_TOAN_PHAT (
    MaThanhToan   CHAR(6)       NOT NULL CONSTRAINT PK_ThanhToanPhat PRIMARY KEY,
    MaKhoanPhat      CHAR(6)       NOT NULL,
    NgayThanhToan DATE          NOT NULL,
    SoTien      DECIMAL(10,2) NOT NULL,
    PhuongThuc      VARCHAR(12)   NOT NULL CONSTRAINT DF_ThanhToanPhat_PhuongThuc DEFAULT 'CASH',
    CONSTRAINT FK_ThanhToanPhat_KhoanPhat FOREIGN KEY (MaKhoanPhat) REFERENCES dbo.KHOAN_PHAT(MaKhoanPhat),
    CONSTRAINT CK_ThanhToanPhat_SoTien CHECK (SoTien > 0),
    CONSTRAINT CK_ThanhToanPhat_PhuongThuc CHECK (PhuongThuc IN ('CASH','TRANSFER','CARD'))
);
GO

/* RBTV liên bảng: hạn trả/ngày trả không trước ngày mượn; bản hỏng không được mượn;
   mỗi độc giả tối đa 3 bản đang giữ cùng lúc. Trigger viết theo hướng xử lý nhiều dòng. */
CREATE TRIGGER dbo.TR_ChiTietMuon_KiemTra
ON dbo.CHI_TIET_MUON
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN dbo.PHIEU_MUON l ON l.MaPhieuMuon = i.MaPhieuMuon
        WHERE i.HanTra < l.NgayMuon OR (i.NgayTra IS NOT NULL AND i.NgayTra < l.NgayMuon)
    )
    BEGIN
        ;THROW 51001, N'Hạn trả và ngày trả phải bằng hoặc sau ngày mượn.', 1;
    END;
    IF EXISTS (
        SELECT 1 FROM inserted i
        JOIN dbo.BAN_SACH c ON c.MaBanSach = i.MaBanSach
        WHERE c.TinhTrangBan <> 'GOOD'
    )
    BEGIN
        ;THROW 51002, N'Chỉ bản sách có tình trạng GOOD được phép cho mượn.', 1;
    END;
    IF EXISTS (
        SELECT 1
        FROM dbo.PHIEU_MUON l
        JOIN dbo.CHI_TIET_MUON li ON li.MaPhieuMuon = l.MaPhieuMuon
        WHERE li.NgayTra IS NULL
        GROUP BY l.MaDocGia
        HAVING COUNT(DISTINCT li.MaBanSach) > 3
    )
    BEGIN
        ;THROW 51003, N'Mỗi độc giả chỉ được giữ tối đa 3 bản sách đang mượn.', 1;
    END;
END;
GO

/* Nếu ngày phiếu được cập nhật, mọi hạn/ngày trả của chi tiết vẫn phải sau ngày mượn. */
CREATE TRIGGER dbo.TR_PhieuMuon_KiemTraNgay
ON dbo.PHIEU_MUON
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN dbo.CHI_TIET_MUON li ON li.MaPhieuMuon = i.MaPhieuMuon
        WHERE li.HanTra < i.NgayMuon
           OR (li.NgayTra IS NOT NULL AND li.NgayTra < i.NgayMuon)
    )
    BEGIN
        ;THROW 51006, N'Ngày phiếu không được chuyển sau hạn trả hoặc ngày trả thực tế.', 1;
    END;
    IF EXISTS (
        SELECT 1
        FROM dbo.PHIEU_MUON l
        JOIN dbo.CHI_TIET_MUON li ON li.MaPhieuMuon = l.MaPhieuMuon
        JOIN (SELECT DISTINCT MaDocGia FROM inserted) r ON r.MaDocGia = l.MaDocGia
        WHERE li.NgayTra IS NULL
        GROUP BY l.MaDocGia
        HAVING COUNT(DISTINCT li.MaBanSach) > 3
    )
    BEGIN
        ;THROW 51007, N'Cập nhật độc giả làm vượt giới hạn 3 bản đang mượn.', 1;
    END;
END;
GO

CREATE TRIGGER dbo.TR_BanSach_KhongDoiTinhTrangKhiMuon
ON dbo.BAN_SACH
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(TinhTrangBan) AND EXISTS (
        SELECT 1 FROM inserted i
        JOIN dbo.CHI_TIET_MUON li ON li.MaBanSach = i.MaBanSach AND li.NgayTra IS NULL
        WHERE i.TinhTrangBan <> 'GOOD'
    )
    BEGIN
        ;THROW 51004, N'Không thể chuyển tình trạng bản sách đang được mượn sang hỏng/mất/bảo trì.', 1;
    END;
END;
GO

CREATE TRIGGER dbo.TR_ThanhToanPhat_GioiHan
ON dbo.THANH_TOAN_PHAT
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF EXISTS (
        SELECT 1 FROM dbo.KHOAN_PHAT f
        JOIN dbo.THANH_TOAN_PHAT p ON p.MaKhoanPhat = f.MaKhoanPhat
        JOIN (SELECT DISTINCT MaKhoanPhat FROM inserted) x ON x.MaKhoanPhat = f.MaKhoanPhat
        GROUP BY f.MaKhoanPhat, f.TienPhat
        HAVING SUM(p.SoTien) > f.TienPhat
    )
    BEGIN
        ;THROW 51005, N'Tổng tiền đã thanh toán không được vượt quá tiền phạt.', 1;
    END;
END;
GO

CREATE TRIGGER dbo.TR_KhoanPhat_KiemTraTien
ON dbo.KHOAN_PHAT
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF UPDATE(TienPhat) AND EXISTS (
        SELECT 1
        FROM inserted i
        JOIN dbo.THANH_TOAN_PHAT p ON p.MaKhoanPhat = i.MaKhoanPhat
        GROUP BY i.MaKhoanPhat, i.TienPhat
        HAVING SUM(p.SoTien) > i.TienPhat
    )
    BEGIN
        ;THROW 51008, N'Không thể giảm tiền phạt thấp hơn tổng đã thanh toán.', 1;
    END;
END;
GO

/* DỮ LIỆU MẪU: danh tính, tổ chức và ấn phẩm đều là dữ liệu giả lập. */
INSERT dbo.THE_LOAI(MaTheLoai, TenTheLoai, MoTa) VALUES
('CT01',N'Tiểu thuyết',N'Tác phẩm văn học hư cấu.'),
('CT02',N'Khoa học phổ thông',N'Sách khoa học dành cho độc giả phổ thông.'),
('CT03',N'Lịch sử',N'Sách lịch sử và tư liệu.'),
('CT04',N'Thiếu nhi',N'Sách phù hợp bạn đọc nhỏ tuổi.'),
('CT05',N'Công nghệ',N'Công nghệ thông tin và kỹ thuật.'),
('CT06',N'Tâm lý',N'Tâm lý học và phát triển bản thân.'),
('CT07',N'Kinh tế',N'Kinh tế và quản trị.'),
('CT08',N'Nghệ thuật',N'Mỹ thuật, âm nhạc và thiết kế.'),
('CT09',N'Địa lý',N'Địa lý và khám phá.'),
('CT10',N'Từ điển',N'Từ điển và sách tra cứu.');

INSERT dbo.NHA_XUAT_BAN(MaNhaXuatBan, TenNhaXuatBan, ThanhPho) VALUES
('PB001',N'Nhà xuất bản Ánh Dương',N'Đồng Nai'),
('PB002',N'Nhà xuất bản Tri Thức Mới',N'TP. Hồ Chí Minh'),
('PB003',N'Nhà xuất bản Sông Xanh',N'Hà Nội'),
('PB004',N'Nhà xuất bản Mầm Non',N'Đồng Nai'),
('PB005',N'Nhà xuất bản Kỹ Thuật Việt',N'TP. Hồ Chí Minh'),
('PB006',N'Nhà xuất bản Học Đường',N'Huế'),
('PB007',N'Nhà xuất bản Phương Nam Giả Lập',N'Cần Thơ'),
('PB008',N'Nhà xuất bản Chân Trời',N'Đà Nẵng'),
('PB009',N'Nhà xuất bản Bách Khoa Mô Phỏng',N'Hà Nội'),
('PB010',N'Nhà xuất bản Nghiên Cứu',N'Đồng Nai');

INSERT dbo.TAC_GIA(MaTacGia, TenTacGia, QuocGia) VALUES
('AU001',N'An Nhiên',N'Việt Nam'),('AU002',N'Minh Hải',N'Việt Nam'),
('AU003',N'Khánh Lam',N'Việt Nam'),('AU004',N'Thành Đạt',N'Việt Nam'),
('AU005',N'Bảo Ngọc',N'Việt Nam'),('AU006',N'Quốc An',N'Việt Nam'),
('AU007',N'Tuệ Minh',N'Việt Nam'),('AU008',N'Gia Hân',N'Việt Nam'),
('AU009',N'Hoàng Phúc',N'Việt Nam'),('AU010',N'Thanh Bình',N'Việt Nam'),
('AU011',N'Lan Chi',N'Việt Nam'),('AU012',N'Nhật Nam',N'Việt Nam');

INSERT dbo.DAU_SACH(MaDauSach, MaTheLoai, MaNhaXuatBan, ISBN, TieuDe, NamXuatBan, TrangThaiDauSach) VALUES
('BK0001','CT01','PB001','9786040000001',N'Ngọn đèn bên sông',2018,'ACTIVE'),
('BK0002','CT01','PB003','9786040000002',N'Ngày trở về',2020,'ACTIVE'),
('BK0003','CT01','PB001','9786040000003',N'Mùa gió mới',2015,'ACTIVE'),
('BK0004','CT02','PB002','9786040000004',N'Vũ trụ trong tầm tay',2019,'ACTIVE'),
('BK0005','CT02','PB005','9786040000005',N'Những bí ẩn của vật chất',2021,'ACTIVE'),
('BK0006','CT02','PB002','9786040000006',N'Thí nghiệm quanh ta',2017,'ACTIVE'),
('BK0007','CT03','PB010','9786040000007',N'Dấu tích một thời',2016,'ACTIVE'),
('BK0008','CT03','PB003','9786040000008',N'Chuyện sử qua tư liệu',2022,'ACTIVE'),
('BK0009','CT04','PB004','9786040000009',N'Khu vườn kỳ thú',2023,'ACTIVE'),
('BK0010','CT04','PB006','9786040000010',N'Bạn nhỏ khám phá',2020,'ACTIVE'),
('BK0011','CT05','PB005','9786040000011',N'Lập trình căn bản',2024,'ACTIVE'),
('BK0012','CT05','PB009','9786040000012',N'An toàn số cho mọi người',2022,'ACTIVE');

INSERT dbo.DAU_SACH_TAC_GIA(MaDauSach, MaTacGia, ThuTuTacGia, VaiTroDongGop) VALUES
('BK0001','AU001',1,N'Tác giả'),('BK0001','AU002',2,N'Đồng tác giả'),
('BK0002','AU003',1,N'Tác giả'),('BK0003','AU004',1,N'Tác giả'),
('BK0004','AU005',1,N'Tác giả'),('BK0004','AU006',2,N'Biên tập khoa học'),
('BK0005','AU006',1,N'Tác giả'),('BK0005','AU007',2,N'Đồng tác giả'),
('BK0006','AU008',1,N'Tác giả'),('BK0006','AU005',2,N'Đồng tác giả'),
('BK0007','AU009',1,N'Tác giả'),('BK0008','AU010',1,N'Tác giả'),
('BK0008','AU011',2,N'Hiệu đính'),('BK0009','AU011',1,N'Tác giả'),
('BK0010','AU012',1,N'Tác giả'),('BK0011','AU007',1,N'Tác giả'),
('BK0011','AU008',2,N'Đồng tác giả'),('BK0012','AU010',1,N'Tác giả');

INSERT dbo.BAN_SACH(MaBanSach, MaDauSach, NgayNhap, TinhTrangBan, MaKe, ChiPhiNhap) VALUES
('CP000001','BK0001','2024-01-10','GOOD','A-01-01',120000),
('CP000002','BK0002','2024-01-10','GOOD','A-01-02',135000),
('CP000003','BK0003','2024-01-10','GOOD','A-01-03',110000),
('CP000004','BK0004','2024-02-01','GOOD','B-01-01',180000),
('CP000005','BK0005','2024-02-01','GOOD','B-01-02',165000),
('CP000006','BK0006','2024-02-01','GOOD','B-01-03',145000),
('CP000007','BK0007','2024-03-05','GOOD','C-01-01',150000),
('CP000008','BK0008','2024-03-05','GOOD','C-01-02',155000),
('CP000009','BK0009','2024-04-01','GOOD','D-01-01',90000),
('CP000010','BK0010','2024-04-01','GOOD','D-01-02',85000),
('CP000011','BK0011','2024-05-15','GOOD','E-01-01',210000),
('CP000012','BK0012','2024-05-15','GOOD','E-01-02',175000),
('CP000013','BK0001','2025-01-10','GOOD','A-02-01',120000),
('CP000014','BK0002','2025-01-10','GOOD','A-02-02',135000),
('CP000015','BK0003','2025-01-10','DAMAGED','A-02-03',110000),
('CP000016','BK0004','2025-02-01','GOOD','B-02-01',180000),
('CP000017','BK0005','2025-02-01','GOOD','B-02-02',165000),
('CP000018','BK0006','2025-02-01','GOOD','B-02-03',145000),
('CP000019','BK0007','2025-03-05','GOOD','C-02-01',150000),
('CP000020','BK0008','2025-03-05','REPAIR','C-02-02',155000);

INSERT dbo.DOC_GIA(MaDocGia, HoTen, NgayThamGia, TrangThaiDocGia) VALUES
('RD0001',N'Bạn đọc Mây Sớm','2024-09-01','ACTIVE'),('RD0002',N'Bạn đọc Sao Mai','2024-09-02','ACTIVE'),
('RD0003',N'Bạn đọc Gió Nhẹ','2024-09-03','ACTIVE'),('RD0004',N'Bạn đọc Nắng Vàng','2024-09-04','ACTIVE'),
('RD0005',N'Bạn đọc Mưa Rào','2024-09-05','ACTIVE'),('RD0006',N'Bạn đọc Trăng Non','2024-09-06','ACTIVE'),
('RD0007',N'Bạn đọc Cánh Diều','2024-09-07','ACTIVE'),('RD0008',N'Bạn đọc Lá Xanh','2024-09-08','ACTIVE'),
('RD0009',N'Bạn đọc Đồi Thông','2024-09-09','ACTIVE'),('RD0010',N'Bạn đọc Bồ Câu','2024-09-10','SUSPENDED'),
('RD0011',N'Bạn đọc Mặt Trời','2024-09-11','ACTIVE'),('RD0012',N'Bạn đọc Sương Mai','2024-09-12','ACTIVE');

INSERT dbo.NHAN_VIEN(MaNhanVien, TenNhanVien, NgayTuyenDung, TrangThaiNhanVien) VALUES
('ST001',N'Thủ thư Ánh', '2022-01-10','ACTIVE'),('ST002',N'Thủ thư Bình','2022-02-10','ACTIVE'),
('ST003',N'Thủ thư Chi','2022-03-10','ACTIVE'),('ST004',N'Thủ thư Duy','2022-04-10','ACTIVE'),
('ST005',N'Thủ thư Giang','2022-05-10','ACTIVE'),('ST006',N'Thủ thư Hà','2022-06-10','ACTIVE'),
('ST007',N'Thủ thư Khoa','2022-07-10','ACTIVE'),('ST008',N'Thủ thư Lan','2022-08-10','ACTIVE'),
('ST009',N'Thủ thư Minh','2022-09-10','ACTIVE'),('ST010',N'Thủ thư Nam','2022-10-10','INACTIVE');

INSERT dbo.PHIEU_MUON(MaPhieuMuon, MaDocGia, MaNhanVien, NgayMuon, TrangThaiPhieu) VALUES
('LN0001','RD0001','ST001','2026-01-01','CLOSED'),
('LN0002','RD0002','ST002','2026-10-20','OPEN'),
('LN0003','RD0003','ST003','2026-01-10','CLOSED'),
('LN0004','RD0004','ST004','2026-10-21','OPEN'),
('LN0005','RD0005','ST005','2025-12-01','CLOSED'),
('LN0006','RD0006','ST006','2025-11-12','CLOSED'),
('LN0007','RD0007','ST007','2026-01-05','CLOSED'),
('LN0008','RD0008','ST008','2026-01-11','CLOSED'),
('LN0009','RD0009','ST009','2026-10-22','OPEN'),
('LN0010','RD0010','ST001','2025-10-10','CLOSED'),
('LN0011','RD0011','ST002','2026-03-02','CLOSED'),
('LN0012','RD0012','ST003','2026-03-05','CLOSED');

INSERT dbo.CHI_TIET_MUON(MaPhieuMuon, MaBanSach, HanTra, NgayTra, TinhTrangKhiTra) VALUES
('LN0001','CP000004','2026-01-08','2026-01-10','GOOD'),
('LN0001','CP000005','2026-01-08','2026-01-08','GOOD'),
('LN0001','CP000006','2026-01-08','2026-01-09','GOOD'),
('LN0002','CP000001','2026-10-27',NULL,NULL),
('LN0002','CP000002','2026-10-27',NULL,NULL),
('LN0003','CP000007','2026-01-20','2026-01-20','GOOD'),
('LN0003','CP000008','2026-01-20','2026-01-25','GOOD'),
('LN0004','CP000009','2026-10-28',NULL,NULL),
('LN0005','CP000010','2025-12-14','2025-12-15','GOOD'),
('LN0006','CP000011','2025-11-19','2025-11-20','GOOD'),
('LN0006','CP000012','2025-11-19','2025-11-20','GOOD'),
('LN0007','CP000013','2026-01-12','2026-01-10','GOOD'),
('LN0008','CP000014','2026-01-18','2026-01-20','GOOD'),
('LN0009','CP000019','2026-10-29',NULL,NULL),
('LN0010','CP000016','2025-10-17','2025-10-20','GOOD'),
('LN0011','CP000017','2026-03-12','2026-03-10','GOOD'),
('LN0011','CP000018','2026-03-12','2026-03-15','GOOD'),
('LN0012','CP000012','2026-03-19','2026-03-20','GOOD'),
('LN0012','CP000007','2026-03-19','2026-03-20','GOOD');

INSERT dbo.KHOAN_PHAT(MaKhoanPhat, MaPhieuMuon, MaBanSach, NgayLap, LoaiPhat, TienPhat, TrangThaiPhat, GhiChu) VALUES
('FN0001','LN0001','CP000004','2026-01-10','OVERDUE',4000,'PAID',N'Trễ 2 ngày; mức minh họa 2.000 đồng/ngày.'),
('FN0002','LN0001','CP000006','2026-01-09','OVERDUE',2000,'PAID',N'Trễ 1 ngày.'),
('FN0003','LN0003','CP000008','2026-01-25','OVERDUE',10000,'PARTIAL',N'Trễ 5 ngày; thanh toán một phần.'),
('FN0004','LN0005','CP000010','2025-12-15','OVERDUE',2000,'PAID',N'Trễ 1 ngày.'),
('FN0005','LN0006','CP000011','2025-11-20','OVERDUE',2000,'UNPAID',N'Trễ 1 ngày.'),
('FN0006','LN0006','CP000012','2025-11-20','OVERDUE',2000,'PAID',N'Trễ 1 ngày.'),
('FN0007','LN0008','CP000014','2026-01-20','OVERDUE',4000,'PAID',N'Trễ 2 ngày.'),
('FN0008','LN0010','CP000016','2025-10-20','OVERDUE',6000,'PARTIAL',N'Trễ 3 ngày; thanh toán một phần.'),
('FN0009','LN0011','CP000018','2026-03-15','OVERDUE',6000,'UNPAID',N'Trễ 3 ngày.'),
('FN0010','LN0012','CP000012','2026-03-20','OVERDUE',2000,'PAID',N'Trễ 1 ngày.');

INSERT dbo.THANH_TOAN_PHAT(MaThanhToan, MaKhoanPhat, NgayThanhToan, SoTien, PhuongThuc) VALUES
('PM0001','FN0001','2026-01-10',4000,'CASH'),
('PM0002','FN0002','2026-01-09',2000,'TRANSFER'),
('PM0003','FN0003','2026-01-26',4000,'CASH'),
('PM0004','FN0004','2025-12-15',2000,'CASH'),
('PM0005','FN0006','2025-11-21',2000,'CARD'),
('PM0006','FN0007','2026-01-21',4000,'CASH'),
('PM0007','FN0008','2025-10-21',2000,'TRANSFER'),
('PM0008','FN0010','2026-03-21',2000,'CASH'),
('PM0009','FN0003','2026-02-01',2000,'TRANSFER'),
('PM0010','FN0008','2025-11-01',2000,'CASH');
GO

/* 20 TRUY VẤN THEO CƠ CẤU RUBRIC */
-- Q1 (Đơn giản): Danh sách bạn đọc đang hoạt động.
SELECT MaDocGia, HoTen, NgayThamGia FROM dbo.DOC_GIA WHERE TrangThaiDocGia = 'ACTIVE';

-- Q2 (Đơn giản): Sách xuất bản từ năm 2020 trở đi.
SELECT MaDauSach, TieuDe, NamXuatBan FROM dbo.DAU_SACH WHERE NamXuatBan >= 2020 ORDER BY NamXuatBan DESC;

-- Q3 (Đơn giản): Các bản sách hỏng hoặc đang bảo trì.
SELECT MaBanSach, MaDauSach, TinhTrangBan, MaKe FROM dbo.BAN_SACH WHERE TinhTrangBan IN ('DAMAGED','REPAIR');

-- Q4 (Đơn giản): Các khoản phạt chưa được thanh toán đủ.
SELECT MaKhoanPhat, LoaiPhat, TienPhat, TrangThaiPhat FROM dbo.KHOAN_PHAT WHERE TrangThaiPhat IN ('UNPAID','PARTIAL');

-- Q5 (Kết nối): Sách cùng tên thể loại và nhà xuất bản.
SELECT b.MaDauSach, b.TieuDe, c.TenTheLoai, p.TenNhaXuatBan
FROM dbo.DAU_SACH b JOIN dbo.THE_LOAI c ON c.MaTheLoai=b.MaTheLoai
JOIN dbo.NHA_XUAT_BAN p ON p.MaNhaXuatBan=b.MaNhaXuatBan;

-- Q6 (Kết nối): Phiếu mượn kèm thông tin độc giả và nhân viên lập phiếu.
SELECT l.MaPhieuMuon, l.NgayMuon, r.HoTen AS TenDocGia, s.TenNhanVien
FROM dbo.PHIEU_MUON l JOIN dbo.DOC_GIA r ON r.MaDocGia=l.MaDocGia
JOIN dbo.NHAN_VIEN s ON s.MaNhanVien=l.MaNhanVien;

-- Q7 (Kết ngoài): Mọi đầu sách, kể cả đầu sách chưa từng được mượn.
SELECT b.MaDauSach, b.TieuDe, COUNT(li.MaBanSach) AS SoLuotMuon
FROM dbo.DAU_SACH b LEFT JOIN dbo.BAN_SACH c ON c.MaDauSach=b.MaDauSach
LEFT JOIN dbo.CHI_TIET_MUON li ON li.MaBanSach=c.MaBanSach
GROUP BY b.MaDauSach, b.TieuDe ORDER BY b.MaDauSach;

-- Q8 (Kết nối): Chi tiết từng bản sách được mượn, độc giả và ngày hẹn trả.
SELECT l.MaPhieuMuon, r.HoTen, b.TieuDe, li.HanTra, li.NgayTra
FROM dbo.PHIEU_MUON l JOIN dbo.DOC_GIA r ON r.MaDocGia=l.MaDocGia
JOIN dbo.CHI_TIET_MUON li ON li.MaPhieuMuon=l.MaPhieuMuon
JOIN dbo.BAN_SACH c ON c.MaBanSach=li.MaBanSach JOIN dbo.DAU_SACH b ON b.MaDauSach=c.MaDauSach;

-- Q9 (Gom nhóm): Số đầu sách theo thể loại, chỉ hiện thể loại có ít nhất hai đầu sách.
SELECT c.TenTheLoai, COUNT(b.MaDauSach) AS SoDauSach
FROM dbo.THE_LOAI c LEFT JOIN dbo.DAU_SACH b ON b.MaTheLoai=c.MaTheLoai
GROUP BY c.TenTheLoai HAVING COUNT(b.MaDauSach)>=2 ORDER BY SoDauSach DESC;

-- Q10 (Gom nhóm): Số phiếu mượn của từng độc giả có phát sinh mượn.
SELECT r.MaDocGia, r.HoTen, COUNT(l.MaPhieuMuon) AS SoPhieuMuon
FROM dbo.DOC_GIA r JOIN dbo.PHIEU_MUON l ON l.MaDocGia=r.MaDocGia
GROUP BY r.MaDocGia, r.HoTen ORDER BY SoPhieuMuon DESC, r.MaDocGia;

-- Q11 (Gom nhóm): Tổng tiền phạt đã thu theo tháng thanh toán.
SELECT YEAR(NgayThanhToan) AS Nam, MONTH(NgayThanhToan) AS Thang, SUM(SoTien) AS TongDaThu
FROM dbo.THANH_TOAN_PHAT GROUP BY YEAR(NgayThanhToan), MONTH(NgayThanhToan)
HAVING SUM(SoTien)>0 ORDER BY Nam, Thang;

-- Q12 (Gom nhóm): Các đầu sách được mượn nhiều nhất, xếp giảm dần theo số lượt.
SELECT b.MaDauSach, b.TieuDe, COUNT(*) AS SoLuotMuon
FROM dbo.DAU_SACH b JOIN dbo.BAN_SACH c ON c.MaDauSach=b.MaDauSach
JOIN dbo.CHI_TIET_MUON li ON li.MaBanSach=c.MaBanSach
GROUP BY b.MaDauSach, b.TieuDe ORDER BY SoLuotMuon DESC, b.MaDauSach;

-- Q13 (Lồng / phép chia): Độc giả đã mượn mọi đầu sách thuộc thể loại CT02.
SELECT r.MaDocGia, r.HoTen
FROM dbo.DOC_GIA r
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.DAU_SACH b WHERE b.MaTheLoai='CT02'
      AND NOT EXISTS (
          SELECT 1 FROM dbo.PHIEU_MUON l JOIN dbo.CHI_TIET_MUON li ON li.MaPhieuMuon=l.MaPhieuMuon
          JOIN dbo.BAN_SACH c ON c.MaBanSach=li.MaBanSach
          WHERE l.MaDocGia=r.MaDocGia AND c.MaDauSach=b.MaDauSach
      )
);

-- Q14 (Lồng): Các đầu sách chưa từng xuất hiện trong bất kỳ lượt mượn nào.
SELECT b.MaDauSach, b.TieuDe FROM dbo.DAU_SACH b
WHERE NOT EXISTS (
    SELECT 1 FROM dbo.BAN_SACH c JOIN dbo.CHI_TIET_MUON li ON li.MaBanSach=c.MaBanSach
    WHERE c.MaDauSach=b.MaDauSach
);

-- Q15 (Lồng / IN): Độc giả từng mượn ít nhất một sách thuộc thể loại có từ 3 đầu sách trở lên.
SELECT r.MaDocGia, r.HoTen FROM dbo.DOC_GIA r
WHERE r.MaDocGia IN (
    SELECT l.MaDocGia FROM dbo.PHIEU_MUON l
    JOIN dbo.CHI_TIET_MUON li ON li.MaPhieuMuon=l.MaPhieuMuon JOIN dbo.BAN_SACH c ON c.MaBanSach=li.MaBanSach
    JOIN dbo.DAU_SACH b ON b.MaDauSach=c.MaDauSach
    WHERE b.MaTheLoai IN (SELECT MaTheLoai FROM dbo.DAU_SACH GROUP BY MaTheLoai HAVING COUNT(*)>=3)
);

-- Q16 (Lồng / ALL): Đầu sách có số lượt mượn bằng mức cao nhất trong toàn bộ các đầu sách.
SELECT b.MaDauSach, b.TieuDe,
       (SELECT COUNT(*) FROM dbo.BAN_SACH c JOIN dbo.CHI_TIET_MUON li ON li.MaBanSach=c.MaBanSach WHERE c.MaDauSach=b.MaDauSach) AS SoLuotMuon
FROM dbo.DAU_SACH b
WHERE (SELECT COUNT(*) FROM dbo.BAN_SACH c JOIN dbo.CHI_TIET_MUON li ON li.MaBanSach=c.MaBanSach WHERE c.MaDauSach=b.MaDauSach)
      >= ALL (SELECT COUNT(*) FROM dbo.BAN_SACH c2 JOIN dbo.CHI_TIET_MUON li2 ON li2.MaBanSach=c2.MaBanSach GROUP BY c2.MaDauSach);

-- Q17 (Lồng / ANY, EXISTS): Đầu sách có ít nhất một bản đã từng được mượn và còn bản tình trạng tốt.
SELECT b.MaDauSach, b.TieuDe FROM dbo.DAU_SACH b
WHERE b.MaDauSach = ANY (SELECT c.MaDauSach FROM dbo.BAN_SACH c JOIN dbo.CHI_TIET_MUON li ON li.MaBanSach=c.MaBanSach)
  AND EXISTS (SELECT 1 FROM dbo.BAN_SACH c2 WHERE c2.MaDauSach=b.MaDauSach AND c2.TinhTrangBan='GOOD');

-- Q18 (Tập hợp UNION): Bạn đọc có phiếu mượn hoặc có khoản phạt chưa thanh toán đủ.
SELECT MaDocGia FROM dbo.PHIEU_MUON
UNION
SELECT l.MaDocGia FROM dbo.KHOAN_PHAT f JOIN dbo.PHIEU_MUON l ON l.MaPhieuMuon=f.MaPhieuMuon WHERE f.TrangThaiPhat IN ('UNPAID','PARTIAL');

-- Q19 (Tập hợp INTERSECT): Đầu sách khoa học phổ thông có ít nhất một bản tình trạng tốt.
SELECT MaDauSach FROM dbo.DAU_SACH WHERE MaTheLoai='CT02'
INTERSECT
SELECT MaDauSach FROM dbo.BAN_SACH WHERE TinhTrangBan='GOOD';

-- Q20 (Tập hợp EXCEPT): Đầu sách chưa có bản nào được mượn.
SELECT MaDauSach FROM dbo.DAU_SACH
EXCEPT
SELECT c.MaDauSach FROM dbo.BAN_SACH c JOIN dbo.CHI_TIET_MUON li ON li.MaBanSach=c.MaBanSach;
GO

/* Các truy vấn kiểm tra số dòng mẫu và trạng thái dữ liệu */
SELECT 'THE_LOAI' AS TenBang, COUNT(*) AS SoDong FROM dbo.THE_LOAI UNION ALL
SELECT 'NHA_XUAT_BAN', COUNT(*) FROM dbo.NHA_XUAT_BAN UNION ALL
SELECT 'TAC_GIA', COUNT(*) FROM dbo.TAC_GIA UNION ALL
SELECT 'DAU_SACH', COUNT(*) FROM dbo.DAU_SACH UNION ALL
SELECT 'DAU_SACH_TAC_GIA', COUNT(*) FROM dbo.DAU_SACH_TAC_GIA UNION ALL
SELECT 'BAN_SACH', COUNT(*) FROM dbo.BAN_SACH UNION ALL
SELECT 'DOC_GIA', COUNT(*) FROM dbo.DOC_GIA UNION ALL
SELECT 'NHAN_VIEN', COUNT(*) FROM dbo.NHAN_VIEN UNION ALL
SELECT 'PHIEU_MUON', COUNT(*) FROM dbo.PHIEU_MUON UNION ALL
SELECT 'CHI_TIET_MUON', COUNT(*) FROM dbo.CHI_TIET_MUON UNION ALL
SELECT 'KHOAN_PHAT', COUNT(*) FROM dbo.KHOAN_PHAT UNION ALL
SELECT 'THANH_TOAN_PHAT', COUNT(*) FROM dbo.THANH_TOAN_PHAT;
GO

/*KIEM TRA RANG BUOC - CHAY LOI*/
UPDATE dbo.BAN_SACH SET TinhTrangBan = 'UNKNOWN' WHERE MaBanSach = 'CP000003'
UPDATE dbo.DAU_SACH SET NamXuatBan = 1400 WHERE MaDauSach = 'BK0001'; 
INSERT dbo.DAU_SACH VALUES ('BK0099','CT01','PB001','9786040000001',N'Sách trùng ISBN',2024,'ACTIVE'); 
INSERT dbo.CHI_TIET_MUON VALUES ('LN0002','CP000003','2026-10-19',NULL,NULL); 
INSERT dbo.CHI_TIET_MUON VALUES ('LN0002','CP000015','2026-10-27',NULL,NULL); 
INSERT dbo.CHI_TIET_MUON VALUES ('LN0002','CP000003','2026-10-27',NULL,NULL), ('LN0004','CP000003','2026-10-28',NULL,NULL); 
INSERT dbo.CHI_TIET_MUON VALUES ('LN0002','CP000003','2026-10-27',NULL,NULL), ('LN0002','CP000013','2026-10-27',NULL,NULL); 
INSERT dbo.THANH_TOAN_PHAT VALUES ('PM0099','FN0003','2026-02-10',5000,'CASH');


/*20 CAU TRUY VAN*/
/* 1. Danh sách độc giả đang hoạt động */
SELECT MaDocGia, HoTen, NgayThamGia
FROM dbo.DOC_GIA
WHERE TrangThaiDocGia = 'ACTIVE';


/* 2. Sách xuất bản từ năm 2020 trở đi */
SELECT MaDauSach, TieuDe, NamXuatBan
FROM dbo.DAU_SACH
WHERE NamXuatBan >= 2020
ORDER BY NamXuatBan DESC;


/* 3. Bản sách hỏng hoặc đang bảo trì */
SELECT MaBanSach, MaDauSach, TinhTrangBan, MaKe
FROM dbo.BAN_SACH
WHERE TinhTrangBan IN ('DAMAGED', 'REPAIR');


/* 4. Khoản phạt chưa thanh toán đủ */
SELECT MaKhoanPhat, LoaiPhat, TienPhat, TrangThaiPhat
FROM dbo.KHOAN_PHAT
WHERE TrangThaiPhat IN ('UNPAID', 'PARTIAL');


/* 5. Sách kèm thể loại và nhà xuất bản */
SELECT ds.MaDauSach, ds.TieuDe, tl.TenTheLoai, nxb.TenNhaXuatBan
FROM dbo.DAU_SACH AS ds
INNER JOIN dbo.THE_LOAI AS tl
    ON tl.MaTheLoai = ds.MaTheLoai
INNER JOIN dbo.NHA_XUAT_BAN AS nxb
    ON nxb.MaNhaXuatBan = ds.MaNhaXuatBan;


/* 6. Phiếu mượn kèm độc giả và nhân viên */
SELECT pm.MaPhieuMuon, pm.NgayMuon, dg.HoTen, nv.TenNhanVien
FROM dbo.PHIEU_MUON AS pm
INNER JOIN dbo.DOC_GIA AS dg
    ON dg.MaDocGia = pm.MaDocGia
INNER JOIN dbo.NHAN_VIEN AS nv
    ON nv.MaNhanVien = pm.MaNhanVien;


/* 7. Mọi đầu sách và số lượt mượn, kể cả sách chưa mượn */
SELECT ds.MaDauSach, ds.TieuDe, COUNT(ctm.MaBanSach) AS SoLuotMuon
FROM dbo.DAU_SACH AS ds
LEFT JOIN dbo.BAN_SACH AS bs
    ON bs.MaDauSach = ds.MaDauSach
LEFT JOIN dbo.CHI_TIET_MUON AS ctm
    ON ctm.MaBanSach = bs.MaBanSach
GROUP BY ds.MaDauSach, ds.TieuDe
ORDER BY ds.MaDauSach;


/* 8. Chi tiết mượn cùng độc giả, đầu sách và hạn trả */
SELECT pm.MaPhieuMuon, dg.HoTen, ds.TieuDe,
       ctm.HanTra, ctm.NgayTra
FROM dbo.PHIEU_MUON AS pm
INNER JOIN dbo.DOC_GIA AS dg
    ON dg.MaDocGia = pm.MaDocGia
INNER JOIN dbo.CHI_TIET_MUON AS ctm
    ON ctm.MaPhieuMuon = pm.MaPhieuMuon
INNER JOIN dbo.BAN_SACH AS bs
    ON bs.MaBanSach = ctm.MaBanSach
INNER JOIN dbo.DAU_SACH AS ds
    ON ds.MaDauSach = bs.MaDauSach;


/* 9. Số đầu sách theo thể loại có ít nhất hai đầu sách */
SELECT tl.TenTheLoai, COUNT(ds.MaDauSach) AS SoDauSach
FROM dbo.THE_LOAI AS tl
LEFT JOIN dbo.DAU_SACH AS ds
    ON ds.MaTheLoai = tl.MaTheLoai
GROUP BY tl.TenTheLoai
HAVING COUNT(ds.MaDauSach) >= 2
ORDER BY SoDauSach DESC;


/* 10. Số phiếu mượn của từng độc giả */
SELECT dg.MaDocGia, dg.HoTen,
       COUNT(pm.MaPhieuMuon) AS SoPhieuMuon
FROM dbo.DOC_GIA AS dg
INNER JOIN dbo.PHIEU_MUON AS pm
    ON pm.MaDocGia = dg.MaDocGia
GROUP BY dg.MaDocGia, dg.HoTen
ORDER BY SoPhieuMuon DESC, dg.MaDocGia;


/* 11. Tổng tiền phạt đã thu theo tháng */
SELECT YEAR(NgayThanhToan) AS Nam,
       MONTH(NgayThanhToan) AS Thang,
       SUM(SoTien) AS TongDaThu
FROM dbo.THANH_TOAN_PHAT
GROUP BY YEAR(NgayThanhToan), MONTH(NgayThanhToan)
HAVING SUM(SoTien) > 0
ORDER BY Nam, Thang;


/* 12. Các đầu sách có nhiều lượt mượn nhất */
SELECT ds.MaDauSach, ds.TieuDe,
       COUNT(*) AS SoLuotMuon
FROM dbo.DAU_SACH AS ds
INNER JOIN dbo.BAN_SACH AS bs
    ON bs.MaDauSach = ds.MaDauSach
INNER JOIN dbo.CHI_TIET_MUON AS ctm
    ON ctm.MaBanSach = bs.MaBanSach
GROUP BY ds.MaDauSach, ds.TieuDe
ORDER BY SoLuotMuon DESC, ds.MaDauSach;


/* 13. Độc giả đã mượn mọi đầu sách thuộc thể loại CT02 */
SELECT dg.MaDocGia, dg.HoTen
FROM dbo.DOC_GIA AS dg
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.DAU_SACH AS ds
    WHERE ds.MaTheLoai = 'CT02'
      AND NOT EXISTS
      (
          SELECT 1
          FROM dbo.PHIEU_MUON AS pm
          INNER JOIN dbo.CHI_TIET_MUON AS ctm
              ON ctm.MaPhieuMuon = pm.MaPhieuMuon
          INNER JOIN dbo.BAN_SACH AS bs
              ON bs.MaBanSach = ctm.MaBanSach
          WHERE pm.MaDocGia = dg.MaDocGia
            AND bs.MaDauSach = ds.MaDauSach
      )
);


/* 14. Đầu sách chưa từng được mượn */
SELECT ds.MaDauSach, ds.TieuDe
FROM dbo.DAU_SACH AS ds
WHERE NOT EXISTS
(
    SELECT 1
    FROM dbo.BAN_SACH AS bs
    INNER JOIN dbo.CHI_TIET_MUON AS ctm
        ON ctm.MaBanSach = bs.MaBanSach
    WHERE bs.MaDauSach = ds.MaDauSach
);


/* 15. Độc giả từng mượn sách thuộc thể loại có từ ba đầu sách trở lên */
SELECT dg.MaDocGia, dg.HoTen
FROM dbo.DOC_GIA AS dg
WHERE dg.MaDocGia IN
(
    SELECT pm.MaDocGia
    FROM dbo.PHIEU_MUON AS pm
    INNER JOIN dbo.CHI_TIET_MUON AS ctm
        ON ctm.MaPhieuMuon = pm.MaPhieuMuon
    INNER JOIN dbo.BAN_SACH AS bs
        ON bs.MaBanSach = ctm.MaBanSach
    INNER JOIN dbo.DAU_SACH AS ds
        ON ds.MaDauSach = bs.MaDauSach
    WHERE ds.MaTheLoai IN
    (
        SELECT MaTheLoai
        FROM dbo.DAU_SACH
        GROUP BY MaTheLoai
        HAVING COUNT(*) >= 3
    )
);


/* 16. Đầu sách đạt số lượt mượn cao nhất */
SELECT ds.MaDauSach, ds.TieuDe,
       (
           SELECT COUNT(*)
           FROM dbo.BAN_SACH AS bs
           INNER JOIN dbo.CHI_TIET_MUON AS ctm
               ON ctm.MaBanSach = bs.MaBanSach
           WHERE bs.MaDauSach = ds.MaDauSach
       ) AS SoLuotMuon
FROM dbo.DAU_SACH AS ds
WHERE
(
    SELECT COUNT(*)
    FROM dbo.BAN_SACH AS bs
    INNER JOIN dbo.CHI_TIET_MUON AS ctm
        ON ctm.MaBanSach = bs.MaBanSach
    WHERE bs.MaDauSach = ds.MaDauSach
)
>= ALL
(
    SELECT COUNT(*)
    FROM dbo.BAN_SACH AS bs2
    INNER JOIN dbo.CHI_TIET_MUON AS ctm2
        ON ctm2.MaBanSach = bs2.MaBanSach
    GROUP BY bs2.MaDauSach
);


/* 17. Đầu sách đã được mượn và có ít nhất một bản tốt */
SELECT ds.MaDauSach, ds.TieuDe
FROM dbo.DAU_SACH AS ds
WHERE ds.MaDauSach = ANY
(
    SELECT bs.MaDauSach
    FROM dbo.BAN_SACH AS bs
    INNER JOIN dbo.CHI_TIET_MUON AS ctm
        ON ctm.MaBanSach = bs.MaBanSach
)
AND EXISTS
(
    SELECT 1
    FROM dbo.BAN_SACH AS bs2
    WHERE bs2.MaDauSach = ds.MaDauSach
      AND bs2.TinhTrangBan = 'GOOD'
);


/* 18. Độc giả có phiếu mượn hoặc có khoản phạt chưa thanh toán đủ */
SELECT MaDocGia
FROM dbo.PHIEU_MUON

UNION

SELECT pm.MaDocGia
FROM dbo.KHOAN_PHAT AS kp
INNER JOIN dbo.PHIEU_MUON AS pm
    ON pm.MaPhieuMuon = kp.MaPhieuMuon
WHERE kp.TrangThaiPhat IN ('UNPAID', 'PARTIAL');


/* 19. Đầu sách thuộc thể loại CT02 có bản tốt */
SELECT MaDauSach
FROM dbo.DAU_SACH
WHERE MaTheLoai = 'CT02'

INTERSECT

SELECT MaDauSach
FROM dbo.BAN_SACH
WHERE TinhTrangBan = 'GOOD';


/* 20. Đầu sách chưa có bản nào từng được mượn */
SELECT MaDauSach
FROM dbo.DAU_SACH

EXCEPT

SELECT bs.MaDauSach
FROM dbo.BAN_SACH AS bs
INNER JOIN dbo.CHI_TIET_MUON AS ctm
    ON ctm.MaBanSach = bs.MaBanSach;
