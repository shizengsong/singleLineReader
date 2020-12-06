FileSelectFile,书籍路径
;书 := FileOpen(书籍路径,"r")
fileread,内存文件,%书籍路径%
缓存字串组:=strsplit(内存文件)

句末标点:=".!?""，。？！；“”`n"
空字符:="`t`n`r"
最长显示:=25
最短显示:=7
显示字串:=""
指针:=1

SplashImage,,b1 h60 w460 c00 fm14 fs14 wm400 ws400,待显示文字,%书籍路径%,阅读器,华文细黑
gosub,下翻行

down::
gosub,下翻行
return

up::
gosub,上翻行
return

上翻行:

return

下翻行:
显示字串:=""
loop,% 缓存字串组.maxindex()
{
	字:=缓存字串组[指针]
	if (instr(空字符,字)){
		指针++
		continue
	}
	if(strlen(显示字串)<最短显示){
		显示字串.=字
		指针++
	}else if(strlen(显示字串)<最长显示){
		if (instr(句末标点,字)){
			显示字串.=字
			指针++
			break
		}else{
			显示字串.=字
			指针++
		}
	}else break	
}
ControlSetText , static2,%显示字串% , 阅读器
return

esc::exitapp