((a,b)=>{a[b]=a[b]||{}})(self,"$__dart_deferred_initializers__")
$__dart_deferred_initializers__.current=function(a,b,c,$){var J,A,C,E,B={
aK5(d){var x,w=d.i(0,"message")
if(w==null)w=""
x=d.i(0,"sender")
if(x==null)x=""
d.i(0,"receiver")
return new B.oc(w,x,d.i(0,"memory"),d.i(0,"deleter"),d.i(0,"poll_id"))},
aTf(d,e,f){return new B.ny(e,f,d,null)},
oc:function oc(d,e,f,g,h){var _=this
_.a=d
_.b=e
_.d=f
_.e=g
_.f=h},
ny:function ny(d,e,f,g){var _=this
_.c=d
_.d=e
_.e=f
_.a=g},
GT:function GT(d,e,f){var _=this
_.d=d
_.e=e
_.f=f
_.r=!0
_.c=_.a=null},
arV:function arV(d){this.a=d},
arZ:function arZ(d,e){this.a=d
this.b=e},
arY:function arY(){},
as_:function as_(d){this.a=d},
as0:function as0(d,e){this.a=d
this.b=e},
arX:function arX(){},
as1:function as1(d){this.a=d},
as2:function as2(d,e){this.a=d
this.b=e},
arW:function arW(d){this.a=d},
arT:function arT(d,e){this.a=d
this.b=e},
arU:function arU(d,e){this.a=d
this.b=e},
arS:function arS(d){this.a=d},
a4D(d,e){return B.aSQ(d,e)},
aSQ(d,e){var x=0,w=A.E(y.i),v,u=2,t=[],s,r,q,p,o
var $async$a4D=A.A(function(f,g){if(f===1){t.push(g)
x=u}for(;;)switch(x){case 0:u=4
x=7
return A.I(A.a3K(A.dz("https://karoki-gallery.onrender.com/messages/get/"+d+"/"+e)),$async$a4D)
case 7:s=g
if(s.b===200){q=s
q=C.au.m5(A.u5(A.u0(q.e)).dA(q.w),null)
v=q
x=1
break}else{q=A.cj("Failed to load messages")
throw A.f(q)}u=2
x=6
break
case 4:u=3
o=t.pop()
r=A.a7(o)
A.fs().$1("Error loading messages: "+A.k(r))
v=[]
x=1
break
x=6
break
case 3:x=2
break
case 6:case 1:return A.C(v,w)
case 2:return A.B(t.at(-1),w)}})
return A.D($async$a4D,w)},
a4E(){var x=0,w=A.E(y.i),v,u=2,t=[],s,r,q,p,o
var $async$a4E=A.A(function(d,e){if(d===1){t.push(e)
x=u}for(;;)switch(x){case 0:u=4
x=7
return A.I(A.a3K(A.dz("https://karoki-gallery.onrender.com/messages/get_group_chats")),$async$a4E)
case 7:s=e
if(s.b===200){q=s
q=C.au.m5(A.u5(A.u0(q.e)).dA(q.w),null)
v=q
x=1
break}else{q=A.cj("Failed to load messages")
throw A.f(q)}u=2
x=6
break
case 4:u=3
o=t.pop()
r=A.a7(o)
A.fs().$1("Error loading messages: "+A.k(r))
v=[]
x=1
break
x=6
break
case 3:x=2
break
case 6:case 1:return A.C(v,w)
case 2:return A.B(t.at(-1),w)}})
return A.D($async$a4E,w)},
a4F(d,e,f){return B.aSR(d,e,f)},
aSR(d,e,f){var x=0,w=A.E(y.v),v=1,u=[],t,s,r,q,p,o,n
var $async$a4F=A.A(function(g,h){if(g===1){u.push(h)
x=v}for(;;)switch(x){case 0:v=3
r=A.dz("https://karoki-gallery.onrender.com/messages/send")
q=y.w
p=A.ao(["Content-Type","application/json"],q,q)
x=6
return A.I(A.L9(r,C.au.px(A.ao(["sender",e,"receiver",f,"message",d],q,q),null),p),$async$a4F)
case 6:t=h
if(t.b!==200){r=A.cj("Failed to send message")
throw A.f(r)}v=1
x=5
break
case 3:v=2
n=u.pop()
s=A.a7(n)
A.fs().$1("Error sending message: "+A.k(s))
x=5
break
case 2:x=1
break
case 5:return A.C(null,w)
case 1:return A.B(u.at(-1),w)}})
return A.D($async$a4F,w)}},D
J=c[1]
A=c[0]
C=c[2]
E=c[7]
B=a.updateHolder(c[3],B)
D=c[9]
B.oc.prototype={}
B.ny.prototype={
af(){var x=A.b([],y.j)
return new B.GT(x,new A.mN(C.dg,$.ax()),A.En(0))}}
B.GT.prototype={
aw(){this.aL()
this.x7()},
l(){var x=this.e
x.M$=$.ax()
x.G$=0
this.f.l()
this.aH()},
HV(){$.a2.k4$.push(new B.arV(this))},
x7(){var x=0,w=A.E(y.v),v=1,u=[],t=this,s,r,q,p,o,n,m,l,k
var $async$x7=A.A(function(d,e){if(d===1){u.push(e)
x=v}for(;;)switch(x){case 0:n=t.a
m=n.c
x=m==="group"?2:4
break
case 2:v=6
x=9
return A.I(B.a4E(),$async$x7)
case 9:s=e
t.a5(new B.arZ(t,s))
t.HV()
v=1
x=8
break
case 6:v=5
l=u.pop()
r=A.a7(l)
t.a5(new B.as_(t))
A.fs().$1("Error loading messages: "+A.k(r))
x=8
break
case 5:x=1
break
case 8:x=3
break
case 4:v=11
x=14
return A.I(B.a4D(n.d,m),$async$x7)
case 14:q=e
t.a5(new B.as0(t,q))
t.HV()
v=1
x=13
break
case 11:v=10
k=u.pop()
p=A.a7(k)
t.a5(new B.as1(t))
A.fs().$1("Error loading messages: "+A.k(p))
x=13
break
case 10:x=1
break
case 13:case 3:return A.C(null,w)
case 1:return A.B(u.at(-1),w)}})
return A.D($async$x7,w)},
u3(){var x=0,w=A.E(y.v),v,u=2,t=[],s=this,r,q,p,o,n
var $async$u3=A.A(function(d,e){if(d===1){t.push(e)
x=u}for(;;)switch(x){case 0:o=C.c.eG(s.e.a.a)
if(J.ch(o)===0){x=1
break}s.a5(new B.as2(s,o))
s.HV()
u=4
q=s.a
x=7
return A.I(B.a4F(o,q.d,q.c),$async$u3)
case 7:u=2
x=6
break
case 4:u=3
n=t.pop()
r=A.a7(n)
A.fs().$1("Send failed: "+A.k(r))
x=6
break
case 3:x=2
break
case 6:case 1:return A.C(v,w)
case 2:return A.B(t.at(-1),w)}})
return A.D($async$u3,w)},
ax8(d,e){if(e==null)return
new A.pH().xt(this.a.d,"delete",e)},
axw(d,e){if(e==null)return
new A.pH().xt(this.a.d,"remain",e)},
K(d){var x,w=this,v=null,u=A.ly(v,v,!0,v,A.cn(w.a.e,v,v,v,v,v,v))
if(w.r)x=C.du
else{x=w.d.length
x=x===0?D.FG:A.aJP(w.f,new B.arW(w),x,D.KH)}return A.kZ(u,v,A.kp(A.b([A.vc(x,1),w.a9J()],y.u),C.ae,C.ao,C.bc),v,v)},
a9R(d){var x,w,v,u,t,s,r,q=this,p=null,o=q.c
o.toString
o=A.bE(o,p,y.x).w
x=q.c
x.toString
x=A.S(x)
w=A.fN(16)
v=q.c
v.toString
v=A.Me(A.S(v).ax.b.bb(0.3),1)
u=A.b([new A.bw(0,C.N,A.aW(C.d.aF(25.5),C.l.F()>>>16&255,C.l.F()>>>8&255,C.l.F()&255),C.h,6)],y.c)
t=y.u
s=A.b([A.jL(D.OE,C.ae,C.ao,C.bc,0),C.iK],t)
r=d.d
if(r!=null)s.push(A.MR(A.fN(12),A.abM(r,p,C.jE,160,p,1/0),C.bH))
s.push(C.iK)
r=d.e
s.push(A.cn((r==null?"Someone":r)+" wants to delete this media",p,p,p,D.a_f,p,p))
s.push(E.B0)
s.push(A.jL(A.b([A.vc(A.NQ(D.a1k,new B.arT(q,d),A.v7(p,p,D.Rq,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p)),1),D.Wk,A.vc(A.NQ(D.a1c,new B.arU(q,d),A.v7(p,p,C.w6,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p,p)),1)],t),C.ae,C.ao,C.bc,0))
return A.hc(p,A.kp(s,C.cg,C.ao,C.bc),C.v,p,new A.ab(0,o.a.a*0.85,0,1/0),new A.du(x.at,p,v,w,u,p,C.aL),p,p,C.ht,D.KG,p,p,p)},
a9J(){var x=null
return A.hc(x,A.jL(A.b([A.vc(A.anx(x,C.d1,!1,x,!0,C.C,x,A.aGw(),this.e,x,x,x,x,x,2,A.qD(x,D.SJ,x,D.KE,x,x,x,x,!0,x,x,x,x,x,x,x,!0,x,x,x,x,x,x,x,x,x,x,x,x,x,x,"Type a message...",x,x,x,x,x,x,x,x,x,!0,!0,!1,x,x,x,x,x,x,x,x,x,x,x,x,x,x),C.a3,!0,x,!0,x,!1,x,C.cJ,x,x,x,x,x,x,x,x,1,x,x,!1,"\u2022",x,x,x,new B.arS(this),x,!1,x,x,!1,x,!0,x,C.dD,x,x,x,x,x,x,x,x,x,x,x,x,!0,C.aF,x,C.iN,x,C.BF,x,x),1),D.Wm,A.kD(x,x,D.LS,x,x,this.ga3m(),x,x,x)],y.u),C.ae,C.ao,C.bc,0),C.v,x,x,x,x,x,x,D.KD,x,x,x)}}
var z=a.updateTypes(["oc(@)","ag<~>()"])
B.arV.prototype={
$1(d){var x=this.a.f,w=x.f
if(w.length!==0){w=C.b.gc1(w).Q
w.toString
x.jp(w,C.dz,C.bZ)}},
$S:5}
B.arZ.prototype={
$0(){var x=this.a,w=J.nm(this.b,new B.arY(),y.A)
w=A.a0(w,w.$ti.h("as.E"))
x.d=w
x.r=!1},
$S:0}
B.arY.prototype={
$1(d){return B.aK5(d)},
$S:z+0}
B.as_.prototype={
$0(){return this.a.r=!1},
$S:0}
B.as0.prototype={
$0(){var x=this.a,w=J.nm(this.b,new B.arX(),y.A)
w=A.a0(w,w.$ti.h("as.E"))
x.d=w
x.r=!1},
$S:0}
B.arX.prototype={
$1(d){return B.aK5(d)},
$S:z+0}
B.as1.prototype={
$0(){return this.a.r=!1},
$S:0}
B.as2.prototype={
$0(){var x=this.a
C.b.C(x.d,new B.oc(this.b,x.a.d,null,null,null))
x.e.oy(C.BA)},
$S:0}
B.arW.prototype={
$2(d,e){var x,w,v,u,t,s,r=null,q=this.a,p=q.d[e],o=p.b,n=o===q.a.d
if(n)o=C.n9
else o=o==="app"?C.P:C.ju
x=p.a
if(x==="pole")q=q.a9R(p)
else{w=q.c
w.toString
w=A.bE(w,r,y.x).w
v=q.c
if(n){v.toString
v=A.S(v).ax.b}else{v.toString
v=A.S(v).at}u=n?12:0
t=n?0:12
if(n)s=r
else{s=q.c
s.toString
s=A.Me(A.S(s).ch,0.5)}q=q.c
if(n){q.toString
q=A.S(q).ax.c}else{q.toString
q=A.S(q).ok.y
q=q==null?r:q.b}t=A.hc(r,A.cn(x,r,r,r,A.dI(r,r,q,r,r,r,r,r,r,r,r,15,r,r,r,r,r,!0,r,r,r,r,r,r,r,r),r,r),C.v,r,new A.ab(0,w.a.a*0.75,0,1/0),new A.du(v,r,s,new A.cv(C.e6,C.e6,new A.aA(u,u),new A.aA(t,t)),r,r,C.aL),r,r,D.KC,D.KJ,r,r,r)
q=t}return new A.ds(o,r,r,q,r)},
$S:647}
B.arT.prototype={
$0(){var x=this.b
return this.a.ax8(x,x.f)},
$S:0}
B.arU.prototype={
$0(){var x=this.b
return this.a.axw(x,x.f)},
$S:0}
B.arS.prototype={
$1(d){return this.a.u3()},
$S:42};(function installTearOffs(){var x=a._instance_0u
x(B.GT.prototype,"ga3m","u3",1)})();(function inheritance(){var x=a.inherit,w=a.inheritMany
x(B.oc,A.P)
x(B.ny,A.Y)
x(B.GT,A.a1)
w(A.jk,[B.arV,B.arY,B.arX,B.arS])
w(A.pZ,[B.arZ,B.as_,B.as0,B.as1,B.as2,B.arT,B.arU])
x(B.arW,A.Aq)})()
A.aA4(b.typeUniverse,JSON.parse('{"ny":{"Y":[],"e":[]},"GT":{"a1":["ny"]}}'))
var y={c:A.a5("u<bw>"),j:A.a5("u<oc>"),u:A.a5("u<e>"),i:A.a5("O<@>"),x:A.a5("iH"),A:A.a5("oc"),w:A.a5("j"),v:A.a5("~")};(function constants(){var x=a.makeConstList
D.a1r=new A.d9("No messages yet",null,null,null,null,null,null,null,null)
D.FG=new A.hK(C.P,null,null,D.a1r,null)
D.KC=new A.aB(0,4,0,4)
D.KD=new A.aB(10,8,10,8)
D.KE=new A.aB(12,0,12,0)
D.KG=new A.aB(12,12,12,12)
D.KH=new A.aB(12,16,12,16)
D.KJ=new A.aB(14,10,14,10)
D.LG=new A.ct(58737,"MaterialIcons",!0)
D.LS=new A.fg(D.LG,null,null,null,null)
D.Ly=new A.ct(58156,"MaterialIcons",!1)
D.LT=new A.fg(D.Ly,18,null,null,null)
D.Wl=new A.eL(6,null,null,null)
D.a_W=new A.q(!0,null,null,null,null,null,16,C.cz,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.a1j=new A.d9("Deletion Poll",null,D.a_W,null,null,null,null,null,null)
D.OE=x([D.LT,D.Wl,D.a1j],y.u)
D.Ij=new A.F(1,1,0.5411764705882353,0.5019607843137255,C.e)
D.Jc=new A.F(1,1,0.3215686274509804,0.3215686274509804,C.e)
D.FX=new A.F(1,1,0.09019607843137255,0.26666666666666666,C.e)
D.Jd=new A.F(1,0.8352941176470589,0,0,C.e)
D.R1=new A.cs([100,D.Ij,200,D.Jc,400,D.FX,700,D.Jd],A.a5("cs<p,F>"))
D.Rq=new A.Cu(D.R1,1,1,0.3215686274509804,0.3215686274509804,C.e)
D.il=new A.aA(50,50)
D.Dq=new A.cv(D.il,D.il,D.il,D.il)
D.SJ=new A.i6(4,D.Dq,C.jC)
D.Wk=new A.eL(10,null,null,null)
D.Wm=new A.eL(8,null,null,null)
D.a_f=new A.q(!0,null,null,null,null,null,14,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null)
D.a1c=new A.d9("Remain",null,null,null,null,null,null,null,null)
D.a1k=new A.d9("Delete",null,null,null,null,null,null,null,null)})()};
(a=>{a["Z3ENXs0kCbPDQCAn7HAW6VwApV8="]=a.current})($__dart_deferred_initializers__);