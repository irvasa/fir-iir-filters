clc;     
clear all;
close all;

fs=1000; %örnekleme frekansımı oluşturdum.
n=[0:1/fs:2];%zaman aralığımı belirledim  

A=7*cos(2*pi*n*30);
B=7*cos(2*pi*n*60);
C=(7+1/5)*cos(2*pi*n*90); % 3 tane sinüzoidal sinyal oluşturdum belirli frekanslarda.

giris_sinyali=A+B+C;% Bu 3 sinuzoidalı birleştirerek sinüzoidal olmayan bir sinyal üretmiş
%oldum.
ma=rms(giris_sinyali)^2;  %giriş sinyalimin gücü 75.29 çıktı. Bu değere göre
%eşit güçte, az güçlü ve daha güçlü gürültü sinyalleri oluşturacağım.

%Giriş sinyalimin zaman-genlik ve frekans spektrumlarını çizdirdim.
plot(n(1:200),giris_sinyali(1:200)); %(1:200 ü ekleme sebebim sadece ilk 200 noktaya
%bakarak sinyalimi daha net bir şekilde görebilmem. 
xlabel('zaman');
ylabel('genlik');
title('giriş sinyali zaman genlik grafiği');
figure;

fourier_giris = fft(giris_sinyali); %sinyalimin fft sini alıp frekans ortamına geçirdim
f = linspace(0,fs,length(fourier_giris)); % frekans eksenimin uzunluğunu belirledim.
x = floor(length(f)/2); 
plot(f(1:x),abs(fourier_giris(1:x)),'LineWidth',2); 
xlabel('frekans');
ylabel('genlik');
title('giriş sinyali frekans genlik grafiği');
grid on;
figure;

D=5*cos(2*pi*n*120);%Gürültü sinyalimi bu 6 tane sinüzoidal dalgayı
E=5*cos(2*pi*n*150);% birleştirerek oluşturdum. 6 tane seçmemin kodun 
F=5*cos(2*pi*n*200);% yapısıyla bir alakası yok sadece gürültüyü karmaşıklaştırmak
G=5*cos(2*pi*n*300);% istedim. Frekans değeri en az 120 den başlayan sinüzoidal dalga kullandım 
H=5*cos(2*pi*n*175);% çünkü giriş sinyalimi oluşturan sinyallerin en büyük frekanslısı 90'dı. Yani
L=5*cos(2*pi*n*135); % belirtildiği gibi gürültünün frekansı giriş sinyalinden fazla oldu.

gurultu=D+E+F+G+H+L; %ilk oluşturulan gürültüm genlik değerlerini
%alttaki rms fonsiyonunda giriş sinyalimle aynı olucak şekilde belirledim.

la=rms(gurultu)^2; %75.82 çıkması için güç değerinin genlik değerlerini  
% ayarladım. Amacım gücünü giriş sinyaliyle aynı yapmaktı. Ps=Pg durumum
% için.

buyukgurultu = 10*gurultu; %gürültünün genliğini 10 katına çıkardım yani
% giriş sinyalinin ve ilk gürültümüzün gücü eşitken gürültüyü giriş
% sinyalinden daha güçlü hala getirdim. Yani Ps<Pg şartı için gürültümüzü
% oluşturdum.
kucukgurultu = (1/10)*gurultu; %Aynı şekilde Ps>Pg için gürültümüzü oluşturdum.

%Giriş sinyaliyle aynı güçteki gürültümün zaman-genlik ve spektrum grafiklerini çizdirdim
plot(n(1:250),gurultu(1:250));
xlabel('zaman');
ylabel('genlik');
title('eşit gürültülü sinyalin zaman genlik grafiği');
figure;

fourier_gurultu = fft(gurultu); % Gürültümü frekans ortamına geçirip frekans spekturumunu
g = linspace(0,fs,length(gurultu)); %çizdirdim. 
z = floor(length(g)/2); 
plot(g(1:z),abs(fourier_gurultu(1:z)),'LineWidth',2);
xlabel('frekans');
ylabel('genlik');
title('eşit gürültülü sinyalin frekans genlik grafiği');
grid on;
figure;

%güç olarak girişe göre küçük olan gürültünün zaman-genlik ve frekans spektrumu
plot(n(1:250),kucukgurultu(1:250)); % Yine aynı işlemleri yaptım zaman-genlik grafiği çizdirdim.
xlabel('zaman');
ylabel('genlik');
title('küçük gürültünün zaman genlik grafiği');
figure;

fougur = fft(kucukgurultu);
g = linspace(0,fs,length(kucukgurultu));  %frekans apekturumu için yine 
z = floor(length(g)/2);                    % fourier dönüşümü.
plot(g(1:z),abs(fougur(1:z)),'LineWidth',2); 
xlabel('frekans');
ylabel('genlik');
title('küçük gürültülü sinyalin frekans genlik grafiği');
grid on;
figure;

%güç olarak girişe göre büyük olan gürültünün zaman-genlik grafiği ve frekans spektrumu
plot(n(1:250),buyukgurultu(1:250));
xlabel('zaman');
ylabel('genlik');
title('büyük gürültünün zaman genlik grafiği');
figure;

fougura = fft(buyukgurultu);
g = linspace(0,fs,length(buyukgurultu));  
z = floor(length(g)/2); 
plot(g(1:z),abs(fougura(1:z)),'LineWidth',2);
xlabel('frekans');
ylabel('genlik');
title('büyük gürültülü sinyalin frekans genlik grafiği');
grid on;
figure;

%FIR filtre tasarımı.FIR filtreler kararlı filtrelerdir. Kararlı olup olmadıklarını
%z düzlemi diagramına bakarak teğit edebiliyoruz. Z düzleminde eğer birim
%çembere yakın bir görüntüsü varsa bu karar oluduklarını gösteriyor. Tabiki
% alçak geçiren bir FIR filtre tasarladık. Çünkü gürültülerin frekansları
% giriş sinyalimden daha büyükler.

Fpass = 95;  % Fpass değerinde fitrem artık bu frekans değerinden sonraki
Fstop = 110;  %sinyalleri geçirmemeye başlıyor bir ölçüde ama tamamen geçirmeyi
Ap = 1;       % bıraktığı frekans değerim Fstop frekansım oluyor. Ap ve As değerleri
As = 30;      % filremin desibel cinsinden yani genlik olarak da bazı değerlerini
% filtrelemesi için varlar ama biz onları bu projemizde kullanmicaz. Çünkü
% zaten gürülltü sinyallerimin frekansları daha büyük olduğundan frekans
% olarak filtreleme gayet yeterli olucaktır.

Firfilter = designfilt('lowpassfir','PassbandFrequency',Fpass,...
'StopbandFrequency',Fstop,'PassbandRipple',Ap,...
'StopbandAttenuation',As,'SampleRate',fs); %belirlediğimiz değerleri
%filtre oluşturma fonksiyonumuzla oluşturduk.

hfvt = fvtool(Firfilter); % fvtool fonsiyonum filtremin frekans yanıtı ve 
% z düzlemindeki yapısını bize grafik olarak veriyor.

%IIR filtre tasarımı. IIR filtremiz kararsızdır. FIR filtrede bahsettiğim
%gibi z-düzlemi diagramına bakarak bunun doğruluğunu teğit ettim. FIR
%filtreler her zaman kararlıyken IIR reler değişkendi. O yüzden kararsız
%bir IIR fitre oluşturdum.

lrrfilter = designfilt('lowpassiir', ...
'PassbandFrequency',Fpass, 'StopbandFrequency',Fstop,'PassbandRipple',1, ...
'StopbandAttenuation',As,'SampleRate',fs); % Fır fitremle aynı değerlere sahip
%bir alçak geçiren filtre oluşturdum yine tek fark kararlılık.

fvtool(lrrfilter)  % FIR daki gibi filtremin frekans karakteristiği ve z düzlemi
% diagramına bu fonksiyon ile ulaşıyorum.

%Gürültünün 3 farklı durmuna göre 3 farklı çıkış buldum. Yani 3 farklı
%gürültüm ile giriş sinyalimi sırasıyla birleştirdim. Yani Ps<Pg, 
%Ps>Pg ve Ps=Pg durumları için 3 çıkış elde ettim.  
giris_esit_cikis= giris_sinyali+gurultu;
giris_buyuk_cikis= giris_sinyali+ kucukgurultu;
giris_kucuk_cikis= giris_sinyali + buyukgurultu;

% Oluşturduğum 3 farklı duruma uygun gürültülü sinyalleri, sırayla hem FIR
% filremden yani kararlı filtremden hem de IIR filtremden yani karasız filtremden
% geçirip çıkış-temiz sinyallerinin zaman-genlik ve spektrum grafiklerini çizdirdim. 

%İlk önce bu çıkış sinyallerimi FIR fitremden geçirdim.
% Ps=Pg eşit olduğu zaman fır filre çıkışları
FIR_g_e_c = filter(Firfilter,giris_esit_cikis); 
plot(n(1:250),FIR_g_e_c(1:250)); %giriş=çıkış zaman genlik
xlabel('zaman');
ylabel('genlik');
title('FIR filtre Ps=Pg zaman-genlik grafiği');
grid on;
figure;
% Yine aynı şekilde ilk zamana göre sonra fourier ile frekans düzlemine
%geçirip çizdirdim grafiklerimi
bedo = fft(FIR_g_e_c);
plot(g(1:z),abs(bedo(1:z)/length(n)),'LineWidth',2); %giriş=çıkış frekans genlik
xlabel('frekans');
ylabel('genlik');
title('FIR filtre Ps=Pg frekans genlik grafiği');
grid on;
figure;

% Ps<Pg eşit olduğu zaman fır filre çıkışları

FIR_g_k_c = filter(Firfilter,giris_kucuk_cikis); 
plot(n(1:250),FIR_g_k_c(1:250)); %giriş<çıkış zaman genlik
xlabel('zaman');
ylabel('genlik');
title('FIR filtre Ps<Pg zaman-genlik grafiği');
grid on;
figure;

bedo2 = fft(FIR_g_k_c);
plot(g(1:z),abs(bedo2(1:z)/length(n)),'LineWidth',2); %giriş<çıkış frekans genlik
xlabel('frekans');
ylabel('genlik');
title('FIR Ps<Pg filtre frekans genlik grafiği');
grid on;
figure;

% Ps>Pg eşit olduğu zaman fır filre çıkışları

FIR_g_b_c = filter(Firfilter,giris_buyuk_cikis); 
plot(n(1:250),FIR_g_b_c(1:250)); %giriş>çıkış zaman genlik
xlabel('zaman');
ylabel('genlik');
title('FIR filtre Ps>Pg zaman-genlik grafiği');
grid on;
figure;

bedo3 = fft(FIR_g_b_c);
plot(g(1:z),abs(bedo3(1:z)/length(n)),'LineWidth',2); %giriş>çıkış frekans genlik
xlabel('frekans');
ylabel('genlik');
title('FIR Ps>Pg filtre frekans genlik grafiği');
grid on;
figure;

%FIR filtremden geçirdim üç düzeyi de şimdi IIR fitremden geçireceğim.
% Ps=Pg eşit olduğu zaman IIR filre çıkışları

IIR_g_e_c = filter(lrrfilter,giris_esit_cikis); 
plot(n(1:250),IIR_g_e_c(1:250)); %giriş=çıkış zaman genlik
xlabel('zaman');
ylabel('genlik');
title('IIR filtre Ps=Pg zaman-genlik grafiği');
grid on;
figure;


bedo4 = fft(IIR_g_e_c);
plot(g(1:z),abs(bedo4(1:z)/length(n)),'LineWidth',2); %giriş=çıkış frekans genlik
xlabel('frekans');
ylabel('genlik');
title('IIR filtre Ps=Pg frekans genlik grafiği');
grid on;
figure;

% Ps<Pg eşit olduğu zaman IIR filre çıkışları

IIR_g_k_c = filter(lrrfilter,giris_kucuk_cikis); 
plot(n(1:250),IIR_g_k_c(1:250)); %giriş<çıkış zaman genlik
xlabel('zaman');
ylabel('genlik');
title('IIR filtre Ps<Pg zaman-genlik grafiği');
grid on;
figure;


bedo5 = fft(IIR_g_k_c);
plot(g(1:z),abs(bedo5(1:z)/length(n)),'LineWidth',2); %giriş<çıkış frekans genlik
xlabel('frekans');
ylabel('genlik');
title('IIR Ps<Pg filtre frekans genlik grafiği');
grid on;
figure;

% Ps>Pg eşit olduğu zaman IIR filre çıkışları

IIR_g_b_c = filter(lrrfilter,giris_buyuk_cikis); 
plot(n(1:250),IIR_g_b_c(1:250)); %giriş>çıkış zaman genlik
xlabel('zaman');
ylabel('genlik');
title('IIR filtre Ps>Pg zaman-genlik grafiği');
grid on;
figure;

bedo6 = fft(IIR_g_b_c);
plot(g(1:z),abs(bedo6(1:z)/length(n)),'LineWidth',2); %giriş<çıkış frekans genlik
xlabel('frekans');
ylabel('genlik');
title('IIR filtre Ps>Pg frekans genlik grafiği');
grid on;

%Oluşan sinyallerin rms genlik  değerlerini yazdırdım.
fprintf('giris rms genliği=%.2f\n',rms(giris_sinyali));
fprintf('eşit güçlü gürültü rms genliği=%.2f\n',rms(gurultu));
fprintf('düşük güçlü gürültü rms genliği=%.2f\n',rms(kucukgurultu));
fprintf('yüksek güçlü gürültü rms genliği=%.2f\n',rms(buyukgurultu));
fprintf('FIR Ps=Pg rms genliği=%.2f\n',rms(FIR_g_e_c));
fprintf('FIR Ps<Pg rms genliği=%.2f\n',rms(FIR_g_k_c));
fprintf('FIR Ps>Pg rms genliği=%.2f\n',rms(FIR_g_b_c));
fprintf('IIR Ps=Pg rms genliği=%.2f\n',rms(IIR_g_e_c));
fprintf('IIR Ps<Pg rms genliği=%.2f\n',rms(IIR_g_k_c));
fprintf('IIR Ps>Pg rms genliği=%.2f\n',rms(IIR_g_b_c));

% Oluşan sinyallerin rms gücünü hesapladım.
fprintf('giris sinyal gucu=%.2f\n',rms(giris_sinyali)^2);
fprintf('esit güçlü gürültü sinyal gücü=%.2f\n',rms(gurultu)^2);
fprintf('düşük güçlü gürültü sinyal gücü=%.2f\n',rms(kucukgurultu)^2);
fprintf('yüksek güçlü gürültü sinyal gücü=%.2f\n',rms(buyukgurultu)^2);
fprintf('FIR Ps=Pg sinyal gücü=%.2f\n',rms(FIR_g_e_c)^2);
fprintf('FIR Ps<Pg sinyal gücü=%.2f\n',rms(FIR_g_k_c)^2);
fprintf('FIR Ps>Pg sinyal gücü=%.2f\n',rms(FIR_g_b_c)^2);
fprintf('IIR Ps=Pg sinyal gücü=%.2f\n',rms(IIR_g_e_c)^2);
fprintf('IIR Ps<Pg sinyal gücü=%.2f\n',rms(IIR_g_k_c)^2);
fprintf('IIR Ps>Pg sinyal gücü=%.2f\n',rms(IIR_g_b_c)^2);
