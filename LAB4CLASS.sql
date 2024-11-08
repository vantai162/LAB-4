USE QuanLyBanHang
GO

--PHAN 1--
--19. Có bao nhiêu hóa đơn không phải của khách hàng đăng ký thành viên mua?--
SELECT COUNT(*) FROM HOADON
WHERE MAKH NOT IN(
	SELECT MAKH FROM KHACHHANG 
	WHERE KHACHHANG.MAKH = HOADON.MAKH
)


--20. Có bao nhiêu sản phẩm khác nhau được bán ra trong năm 2006.--
SELECT COUNT(SANPHAM.MASP) AS SOSPDAMUA
FROM SANPHAM
JOIN CTHD ON CTHD.MASP = SANPHAM.MASP
JOIN HOADON ON HOADON.SOHD = CTHD.SOHD
WHERE  YEAR(NGHD) = 2006

--21. Cho biết trị giá hóa đơn cao nhất, thấp nhất là bao nhiêu?--
SELECT MAX(TRIGIA) AS HOADONCAONHAT,MIN(TRIGIA) AS HOADONTHAPNHAT
FROM HOADON

--22. Trị giá trung bình của tất cả các hóa đơn được bán ra trong năm 2006 là bao nhiêu?--
SELECT AVG(TRIGIA) AS TRUNGBINHGIA
FROM HOADON
WHERE YEAR(NGHD) = 2006
--23. Tính doanh thu bán hàng trong năm 2006.--
SELECT SUM(TRIGIA) AS DOANHTHU
FROM	HOADON
WHERE	YEAR(NGHD) = 2006
--24. Tìm số hóa đơn có trị giá cao nhất trong năm 2006.--
SELECT HOADON.SOHD,TRIGIA
FROM HOADON
WHERE YEAR(NGHD) = 2006 AND TRIGIA = (
	SELECT MAX(TRIGIA) FROM HOADON )

--25. Tìm họ tên khách hàng đã mua hóa đơn có trị giá cao nhất trong năm 2006.--
SELECT HOADON.SOHD,TRIGIA,HOTEN
FROM HOADON
JOIN KHACHHANG ON HOADON.MAKH = KHACHHANG.MAKH
WHERE YEAR(NGHD) = 2006 AND TRIGIA = (
	SELECT MAX(TRIGIA) FROM HOADON )

--26. In ra danh sách 3 khách hàng (MAKH, HOTEN) có doanh số cao nhất.--
SELECT TOP 3 MAKH,HOTEN
FROM KHACHHANG
ORDER BY DOANHSO DESC
--27. In ra danh sách các sản phẩm (MASP, TENSP) có giá bán bằng 1 trong 3 mức giá cao nhất.--
SELECT MASP,TENSP
FROM SANPHAM
WHERE GIA IN (
	SELECT DISTINCT TOP 3 GIA
	FROM SANPHAM
	ORDER BY GIA DESC
)
ORDER BY GIA DESC
--28. In ra danh sách các sản phẩm (MASP, TENSP) do “Thai Lan” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của tất cả các sản phẩm).--
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Thai Lan' 
  AND GIA IN (
      SELECT DISTINCT TOP 3 GIA
      FROM SANPHAM
      ORDER BY GIA DESC
  )


--29. In ra danh sách các sản phẩm (MASP, TENSP) do “Trung Quoc” sản xuất có giá bằng 1 trong 3 mức giá cao nhất (của sản phẩm do “Trung Quoc” sản xuất).--
SELECT MASP, TENSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc' 
  AND GIA IN (
      SELECT DISTINCT TOP 3 GIA
      FROM SANPHAM
      ORDER BY GIA DESC
  )
--30. In ra danh sách 3 khách hàng có doanh số cao nhất (sắp xếp theo kiểu xếp hạng).--
SELECT TOP 3 MAKH,HOTEN
FROM KHACHHANG
ORDER BY DOANHSO DESC

--Phan 02--
USE QuanLyHocVu
GO
--19. Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất. --
SELECT TOP 1 MAKHOA,TENKHOA
FROM KHOA
ORDER BY NGTLAP

--20. Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”. --
SELECT GIAOVIEN.MAGV,HOTEN
FROM GIAOVIEN
WHERE HOCHAM IN ('GS','PGS')
--21. Thống kê có bao nhiêu giáo viên có học vị là “CN”, “KS”, “Ths”, “TS”, “PTS” trong mỗi khoa. --
SELECT TENKHOA, COUNT(MAGV) AS SOLUONGGV
FROM GIAOVIEN
JOIN KHOA ON KHOA.MAKHOA = GIAOVIEN.MAKHOA
WHERE HOCVI IN ('CN','KS', 'Ths', 'TS', 'PTS')
GROUP BY TENKHOA
--22. Mỗi môn học thống kê số lượng học viên theo kết quả (đạt và không đạt). --
SELECT MAMH, KQUA, COUNT(MAHV) SL
FROM KETQUATHI A
WHERE NOT EXISTS (
	SELECT 1 
	FROM KETQUATHI B 
	WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
)
GROUP BY MAMH, KQUA
--23. Tìm giáo viên (mã giáo viên, họ tên) là giáo viên chủ nhiệm của một lớp, đồng thời dạy cho lớp đó ít nhất một môn học. --
SELECT MAGV,HOTEN
FROM GIAOVIEN
WHERE MAGV IN (
	SELECT DISTINCT MAGV
	FROM GIANGDAY
	JOIN LOP ON GIANGDAY.MALOP = LOP.MALOP
	WHERE MAGV = MAGVCN
	)

--24. Tìm họ tên lớp trưởng của lớp có sỉ số cao nhất. --
SELECT HO,TEN
FROM HOCVIEN
JOIN LOP ON LOP.TRGLOP = HOCVIEN.MAHV
WHERE LOP.MALOP = (
	SELECT TOP 1 MALOP
	FROM LOP
	ORDER BY SISO DESC
)
--25. * Tìm họ tên những LOPTRG thi không đạt quá 3 môn (mỗi môn đều thi không đạt ở tất cả các lần thi).--
SELECT HO, TEN HOTEN FROM HOCVIEN
WHERE MAHV IN (
	SELECT MAHV FROM KETQUATHI A
	WHERE MAHV IN (
		SELECT TRGLOP FROM LOP
	) AND NOT EXISTS (
		SELECT 1 FROM KETQUATHI B 
		WHERE A.MAHV = B.MAHV AND A.MAMH = B.MAMH AND A.LANTHI < B.LANTHI
	) AND KQUA = 'Khong Dat'
	GROUP BY MAHV
	HAVING COUNT(MAMH) >= 3
)
--Phan 03--
USE QuanLyBanHang
GO
--31. Tính tổng số sản phẩm do “Trung Quoc” sản xuất. --
SELECT COUNT(MASP) AS SOSP
FROM SANPHAM
WHERE NUOCSX = 'Trung Quoc'
--32. Tính tổng số sản phẩm của từng nước sản xuất. --
SELECT NUOCSX,COUNT(MASP) AS SOSP
FROM SANPHAM
GROUP BY NUOCSX
--33. Với từng nước sản xuất, tìm giá bán cao nhất, thấp nhất, trung bình của các sản phẩm. --
SELECT NUOCSX, MAX(SANPHAM.GIA) CAO_NHAT,MIN(SANPHAM.GIA) THAP_NHAT,AVG(SANPHAM.GIA) TRUNG_BINH
FROM SANPHAM
GROUP BY NUOCSX
--34. Tính doanh thu bán hàng mỗi ngày. --
SELECT HOADON.NGHD, SUM(TRIGIA) AS DOANHTHU
FROM	HOADON
GROUP BY HOADON.NGHD
--35. Tính tổng số lượng của từng sản phẩm bán ra trong tháng 10/2006. --
SELECT CTHD.MASP, SUM(CTHD.SL) AS SL
FROM CTHD
JOIN HOADON ON HOADON.SOHD = CTHD.SOHD
WHERE YEAR(NGHD) = 2006 AND MONTH(NGHD) = 10
GROUP BY MASP
--36. Tính doanh thu bán hàng của từng tháng trong năm 2006. --
SELECT MONTH(HOADON.NGHD) THANG, SUM(TRIGIA) AS DOANHTHU
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(HOADON.NGHD)
--37. Tìm hóa đơn có mua ít nhất 4 sản phẩm khác nhau. --
SELECT SOHD 
FROM CTHD
GROUP BY SOHD 
HAVING COUNT(DISTINCT MASP) >= 4
--38. Tìm hóa đơn có mua 3 sản phẩm do “Viet Nam” sản xuất (3 sản phẩm khác nhau). --
SELECT SOHD 
FROM CTHD
JOIN SANPHAM ON CTHD.MASP = SANPHAM.MASP
WHERE NUOCSX = 'Viet Nam'
GROUP BY SOHD
HAVING COUNT(DISTINCT CTHD.MASP) = 3
--39. Tìm khách hàng (MAKH, HOTEN) có số lần mua hàng nhiều nhất.  --
SELECT MAKH, HOTEN FROM (
	SELECT HD.MAKH, HOTEN, RANK() OVER (ORDER BY COUNT(HD.MAKH) DESC) RANK_SOLAN 
	FROM HOADON HD INNER JOIN KHACHHANG KH 
	ON HD.MAKH = KH.MAKH
	GROUP BY HD.MAKH, HOTEN
) A
WHERE RANK_SOLAN = 1
--40. Tháng mấy trong năm 2006, doanh số bán hàng cao nhất ? --
SELECT TOP 1 MONTH(HOADON.NGHD) THANG, SUM(TRIGIA) AS DOANHTHU
FROM HOADON
WHERE YEAR(NGHD) = 2006
GROUP BY MONTH(HOADON.NGHD)
ORDER BY DOANHTHU DESC

--41. Tìm sản phẩm (MASP, TENSP) có tổng số lượng bán ra thấp nhất trong năm 2006. --
SELECT TOP 1 SANPHAM.MASP,TENSP 
FROM SANPHAM
JOIN CTHD ON CTHD.MASP = SANPHAM.MASP
JOIN HOADON ON HOADON.SOHD = CTHD.SOHD
WHERE YEAR(NGHD) = 2006
ORDER BY SL
--42. *Mỗi nước sản xuất, tìm sản phẩm (MASP,TENSP) có giá bán cao nhất. --
SELECT NUOCSX, MASP, TENSP, GIA
FROM SANPHAM AS SP
WHERE GIA = (
    SELECT MAX(GIA)
    FROM SANPHAM
    WHERE NUOCSX = SP.NUOCSX
);
--43. Tìm nước sản xuất sản xuất ít nhất 3 sản phẩm có giá bán khác nhau. --
SELECT NUOCSX FROM SANPHAM 
GROUP BY NUOCSX
HAVING COUNT(DISTINCT GIA) >= 3

--44. *Trong 10 khách hàng có doanh số cao nhất, tìm khách hàng có số lần mua hàng nhiều nhất.--
SELECT MAKH, HOTEN FROM (
	SELECT TOP 10 HD.MAKH, HOTEN, DOANHSO, RANK() OVER (ORDER BY COUNT(HD.MAKH) DESC) RANK_SOLAN 
	FROM HOADON HD INNER JOIN KHACHHANG KH 
	ON HD.MAKH = KH.MAKH
	GROUP BY HD.MAKH, HOTEN, DOANHSO
	ORDER BY DOANHSO DESC
) A
WHERE RANK_SOLAN = 1
--Phan 04--
USE QuanLyHocVu
GO
--26. Tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất. --
SELECT HOCVIEN.MAHV,HO,TEN,COUNT(*) AS XEPHANG
FROM HOCVIEN
JOIN KETQUATHI ON KETQUATHI.MAHV = HOCVIEN.MAHV
WHERE KETQUATHI.DIEM >= 9
GROUP BY HOCVIEN.MAHV,HO,TEN
ORDER BY XEPHANG DESC


--27. Trong từng lớp, tìm học viên (mã học viên, họ tên) có số môn đạt điểm 9, 10 nhiều nhất. --

--28. Trong từng học kỳ của từng năm, mỗi giáo viên phân công dạy bao nhiêu môn học, bao nhiêu lớp. --
SELECT HOCKY,NAM,GIANGDAY.MAGV, COUNT(GIANGDAY.MAMH) MONHOC, COUNT(GIANGDAY.MALOP) LOP
FROM GIANGDAY
GROUP BY HOCKY,NAM,GIANGDAY.MAGV
--29. Trong từng học kỳ của từng năm, tìm giáo viên (mã giáo viên, họ tên) giảng dạy nhiều nhất. --
SELECT TOP 1 HOCKY,NAM,GIANGDAY.MAGV, COUNT(GIANGDAY.MAMH) MONHOC, COUNT(GIANGDAY.MALOP) LOP
FROM GIANGDAY
GROUP BY HOCKY,NAM,GIANGDAY.MAGV
ORDER BY MONHOC DESC
--30. Tìm môn học (mã môn học, tên môn học) có nhiều học viên thi không đạt (ở lần thi thứ 1) nhất. --
--31. Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi thứ 1). --
--32. * Tìm học viên (mã học viên, họ tên) thi môn nào cũng đạt (chỉ xét lần thi sau cùng). --
--33. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi thứ 1). --
--34. * Tìm học viên (mã học viên, họ tên) đã thi tất cả các môn và đều đạt (chỉ xét lần thi sau cùng). --
--35. ** Tìm học viên (mã học viên, họ tên) có điểm thi cao nhất trong từng môn (lấy điểm ở lần thi sau cùng). --
