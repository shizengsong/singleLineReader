#singleinstance force
Menu, Tray,Icon ,icon.ico
CoordMode,mouse,screen
try{
	FileSelectFile,书籍路径
	if errorlevel
		gosub,显示窗口
}

文字大小:=40, 文本颜色:=303050, 字体:= "华文细黑"
开启监测:=1
最长显示:=22, 最优显示区间_长:=15, 最优显示区间_短:=10, 最短显示:=7
SplitPath, 书籍路径 , , , , 书名,
fileread, 内存文件 , %书籍路径%
句末标点:=";,.!?""，。？！；”、《》：`n", 空字符:=" 　`r`n`t", 显示字串:=""
阅读位置:={}, 标点位置:=段数:=指针:=1
IniRead, 读取的位置, 阅读文件.ini, 阅读位置, % 书籍路径, 1
if(读取的位置!="error"){
	阅读位置[1] :=读取的位置
}else 阅读位置[1]:=1

显示窗口:
Gui,单行阅读器_按ESC退出:new
gui,单行阅读器_按ESC退出:color,ffffff
gui,font,s%文字大小% c%文本颜色%,%字体%

阅读文本宽度:=A_ScreenWidth*0.95, 阅读文本高度:=200
坐标x:=A_ScreenWidth*0.05 , 坐标y:=A_ScreenHeight/2-阅读文本高度/2
gui,add,text,x%坐标x% y%坐标y% h%阅读文本高度% w%阅读文本宽度% v阅读显示 r1,测试文本

图像长度:=500,  坐标y:=A_ScreenHeight/2,  坐标x:=(A_ScreenWidth-图像长度)/2
gui,add,picture,v分割线 x%坐标x% y%坐标y% w%图像长度% h-1,分割线.png
Gui,show,Maximize,单行阅读器_按ESC退出

敏感度:=3, 鼠标位移下线:=A_ScreenHeight/2+20, 鼠标位移上线:=鼠标位移下线-敏感度

gosub,下翻页
gosub,上翻页
是否开启鼠标监测(开启监测)
return

是否开启鼠标监测(是否){
	if(是否==1){
		settimer,鼠标位移翻页,100
	}else	settimer,鼠标位移翻页,off
}

#ifwinactive 单行阅读器_按ESC退出

-::
if(敏感度 >2)
	敏感度--,鼠标位移上线:=鼠标位移下线-敏感度
tooltip,% 敏感度
settimer,关闭tooltip,-1000
return

=::
敏感度++,鼠标位移上线:=鼠标位移下线-敏感度
tooltip,% 敏感度
settimer,关闭tooltip,-1000
return

关闭tooltip:
tooltip
return

up::gosub,上翻页
down::gosub,下翻页
esc::gosub,退出
rctrl::	
if(!内存文件)
	return
是否开启鼠标监测(开启监测:=!开启监测)
return

鼠标位移翻页:
	wingettitle,活动窗口名,A
	if(活动窗口名!="单行阅读器_按ESC退出"){
		是否开启鼠标监测(开启监测:=0)
		return
	}
	mousegetpos,x,y
	if( y>鼠标位移下线){
		GuiControl,单行阅读器_按ESC退出:,分割线,*w%图像长度% *h-1 分割线_2.png
		gosub,向下测量
		gosub,下翻页
		blockinput,mousemove
		sleep,50
		GuiControl,单行阅读器_按ESC退出:,分割线,*w%图像长度% *h-1 分割线.png
		mousemove,% x,% 鼠标位移上线,1
		sleep,150
		blockinput,mousemoveoff
	}
return

上翻页:
	gosub,向上测量
	if(!内存文件)
		return
	if(阅读位置[段数-1]){
		if(阅读位置[段数-2] && 已下翻 ){
			段数-=2, 已下翻:=0
		}else 段数--
		显示字串:=阅读字串(段数)
		guicontrol, 单行阅读器_按ESC退出:, 阅读显示, %显示字串%
		已上翻:=1
	}
return

下翻页:
	gosub,向下测量
	if(!内存文件)
		return
	if(已上翻)
		段数++, 已上翻:=0
	显示字串:=阅读字串(段数)
	guicontrol, 单行阅读器_按ESC退出:, 阅读显示, %显示字串%
	段数++, 已下翻:=1
return

向下测量:
	if(!内存文件)
		return
	if(阅读位置[段数+1])
		return
	指针:=阅读位置[段数]
	已有字数:=已有标点:=0
	阅读位置[段数+1]:=指针+9
	loop
	{	
		字:=substr(内存文件,指针,1)
		if(字=="`n"){
			if(已有字数>0)
				阅读位置[段数+1]:=指针+1, break
		}
		if(!instr(空字符,字))
			已有字数+=1
		if(已有字数<=最短显示){
			指针++,	continue
		}else if(已有字数>最短显示 && 已有字数<=最优显示区间_短){
			if(instr(句末标点,字))			
				判断连续标点("下"), 已有标点:=1
		}else if(已有字数>最优显示区间_短 && 已有字数<=最优显示区间_长){
			if(instr(句末标点,字))			
				判断连续标点("下"), break
		}else if(已有字数>最优显示区间_长 && 已有字数<最长显示){
			if(instr(句末标点,字) && !已有标点)
				判断连续标点("下"), break
		}else if(已有字数>=最长显示){
				break
		}
		if(A_index>200){
			msgbox,空字符太多 请检查文件
			exitapp
		}
		指针++
	}
return

F1::msgbox,% "已有字数:" . 已有字数 . "`t最长显示:" . 最长显示

判断连续标点(方向){
	global
	if(instr(句末标点,substr(内存文件,指针+1,1))){
		指针++
	}
	if(方向=="下"){
		阅读位置[段数+1]:=指针+1
	}else if(方向=="上"){
		阅读位置[段数-1]:=指针+1
	}else msgbox, 函数_判断连续标点_请输入方向
}

向上测量:
	if(!内存文件)
		return
	if(阅读位置[段数-1])
		return					;这句命令好像有问题
	指针:=阅读位置[段数]
	if(指针<=9)						;文件开头,返回
		return
	已有字数:=0, 已有标点:=0
	阅读位置[段数-1]:=指针-9
	loop
	{	
		指针--
		字:=substr(内存文件,指针,1)
		if(!instr(空字符,字))
			已有字数+=1
		if(字=="`n"){
			if(已有字数>4)
				阅读位置[段数-1]:=指针+1, break
		}
		if(已有字数<=最短显示){
			continue
		}else if(已有字数>最短显示 && 已有字数<=最优显示区间_短){
			if(instr(句末标点,字))		
				判断连续标点("上"),已有标点:=1
		}else if(已有字数>最优显示区间_短 && 已有字数<=最优显示区间_长){
			if(instr(句末标点,字))		
				判断连续标点("上"), break
		}else if(已有字数>最优显示区间_长 && 已有字数<最长显示){
			if(instr(句末标点,字) && !已有标点)
				判断连续标点("上"), break
		}else if(已有字数==最长显示)
				break
		if(A_index>200){
			msgbox,空字符太多 请检查文件
			exitapp
		}
	}
return

阅读字串(段数){
	global 全书字组,阅读位置,内存文件
	指针:=阅读位置[段数]
	while(指针<阅读位置[段数+1]){					;全书字组[指针]
		获得字串 .=substr(内存文件,指针,1), 指针++
	}
	获得字串:=Trim(获得字串)
	StringReplace, 获得字串, 获得字串,% " ",, All
	StringReplace, 获得字串, 获得字串,`r`n,, All
	return 获得字串
}

单行阅读器_按ESC退出GuiClose:								;终于解决这个老大难问题,ahk还是高科技的
gosub,退出
return

单行阅读器_按ESC退出GuiSize:								;背景窗口最小化事件
if (errorlevel==1){
	是否开启鼠标监测(0)
}else if(errorlevel==2){
	if (已最小化){
		sleep,300
		段数--
	}
	是否开启鼠标监测(开启监测)
	mousemove,% A_ScreenWidth*0.4,% 鼠标位移上线,
	winactivate,单行阅读器_按ESC退出
}
return

退出:
if(书籍路径 && 阅读位置[段数-1])
	IniWrite,% 阅读位置[段数-1],阅读文件.ini, 阅读位置, % 书籍路径
exitapp