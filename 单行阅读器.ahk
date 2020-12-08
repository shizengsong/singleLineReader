#singleinstance force
CoordMode,mouse,screen
try{
	FileSelectFile,书籍路径
	if errorlevel
		gosub,显示窗口
}

;书籍路径:="Z:\书籍\查拉斯图拉如是说.TXT"
最长显示:=24
最优显示区间_长:=15
最优显示区间_短:=10
最短显示:=7
SplitPath, 书籍路径 , , , , 书名, 
fileread, 内存文件 , %书籍路径%

句末标点:=";,.!?""，。？！；”、《》：`n"
空字符:=" 　`r`n`t"
显示字串:=""

阅读位置:=[]
阅读位置[段数] := 标点位置:=段数:=指针:=1

IniRead, 读取的位置, 阅读文件.ini, 阅读位置, % 书籍路径, 1
if(读取的位置){
	阅读位置[1] :=读取的位置
}

显示窗口:
Gui,阅读背景窗口:new
gui,阅读背景窗口:color,ffffff
Gui,show,Maximize,阅读背景窗口
阅读窗宽度:=A_ScreenWidth*0.95
阅读窗高度:=200
鼠标位移下线:=A_ScreenHeight/2+2
鼠标位移上线:=A_ScreenHeight/2

SplashImage,,b h%阅读窗高度% w%阅读窗宽度% c01 fm12 fs50 wm400 ws400 cwwhite,%a_space%,%a_space%, 单行阅读器,新宋体

if(!内存文件)
	return

gosub,向下测量
gosub,下翻页

开启监测:=1
if (开启监测)
	settimer,鼠标位移翻页,100
return

#ifwinactive 阅读背景窗口
esc::gosub,退出
up::gosub,上翻页
down::
gosub,向下测量
gosub,下翻页
return

rctrl::
if(!内存文件)
	return
if(开启监测:=!开启监测){
	settimer,鼠标位移翻页,100
}else settimer,鼠标位移翻页,off
return

鼠标位移翻页:
	mousegetpos,x,y
	wingettitle,活动窗口名,A
	if( y>鼠标位移下线 && 活动窗口名=="阅读背景窗口"){
		gosub,向下测量
		gosub,下翻页
		blockinput,mousemove
		mousemove,% A_ScreenWidth*0.4,% 鼠标位移上线,2
		sleep,200
		blockinput,mousemoveoff
	}
return

#ifwinexist,单行阅读器

上翻页:
	if(!内存文件)
		return
	if(段数>1){
		if(已下翻){
			段数-=2
			已下翻:=0
		}else 段数--
		显示字串:=阅读字串(段数)
		ControlSetText , static2, %显示字串% , 单行阅读器
		已上翻:=1
	}
return


下翻页:
if(!内存文件)
	return
if(已上翻){
	段数++
	已上翻:=0
}
显示字串:=阅读字串(段数)
ControlSetText , static2, %显示字串% , 单行阅读器 
段数++
已下翻:=1
return

向下测量:
	if(!内存文件)
		return
	指针:=阅读位置[段数]
	已有字数:=0
	已有标点:=0
	阅读位置[段数+1]:=指针+9
	loop
	{	
		字:=substr(内存文件,指针,1)
		if(字=="`n"){
			if(已有字数>0){
				阅读位置[段数+1]:=指针+1
				break
			}
		}
		if(!instr(空字符,字)){
			已有字数+=1
		}
		if(已有字数<=最短显示){
			指针++
			continue
		}else if(已有字数>最短显示 && 已有字数<=最优显示区间_短){
			if(instr(句末标点,字)){			
				gosub,判断标点
				已有标点:=1
			}
		}else if(已有字数>最优显示区间_短 && 已有字数<=最优显示区间_长){
			if(instr(句末标点,字)){			
				gosub,判断标点
				break
			}
		}else if(已有字数>最优显示区间_长 && 已有字数<最长显示){
			if(instr(句末标点,字) && !已有标点){
				gosub,判断标点
				break
			}
		}else if(已有字数==最长显示){
				break
		}
		if(A_index>200){
			msgbox,空字符太多 请检查文件
			exitapp
		}
		指针++
	}
return

判断标点:
	if(instr(句末标点,substr(内存文件,指针+1,1))){
		指针++
	}
	阅读位置[段数+1]:=指针+1
return

阅读字串(段数){
	global 全书字组,阅读位置,内存文件
	指针:=阅读位置[段数]
	while(指针<阅读位置[段数+1]){
		获得字串 .=substr(内存文件,指针,1)				;全书字组[指针]
		指针++
	}
	获得字串:=Trim(获得字串)
	StringReplace, 获得字串, 获得字串,% " ",, All
	StringReplace, 获得字串, 获得字串,`r`n,, All
;	StringReplace, 获得字串, 获得字串,,, All
	return 获得字串
}

阅读背景窗口GuiClose:								;终于解决这个老大难问题,ahk还是高科技的
gosub,退出
return

阅读背景窗口GuiSize:								;背景窗口最小化事件
if (errorlevel==1){
	WinHide,单行阅读器
}else if(errorlevel==2){
	if (已最小化){
		sleep,300
		段数--
	}
	WinShow,单行阅读器
	winactivate,阅读背景窗口
}
return

退出:
if(书籍路径 && 阅读位置[段数-1])
	IniWrite,% 阅读位置[段数-1],阅读文件.ini, 阅读位置, % 书籍路径 
exitapp