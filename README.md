# Smart Chiller


**Anggota Kelompok SSF 19:**
+ Irfan Yusuf Khaerullah -  2206813290
+ Raditya Akhila Ganapati - 2206016151
+ Azriel Dimas Ash-Shidiqi - 2206059414
+ Darren Adam Dewantoro  - 2206816600

# Background And Solution

Perkembangan teknologi dapat mempengaruhi kehidupan termasuk bagaimana kita dapat menyimpan dan menjaga kualiats makanan. Chiller adalah salah satu alat penting yang ada dibutuhkan dalam rumah tangga ataupun indsutri makanan dalam menajaga makanan agar tetap fresh dan sehat. Namun dalam pemanfaatan chiller masih terdapat tantangan dalam penggunaanya seperti mendeteksi suhu agar chiller agar makanan yang disimpan agar tetap fresh, Suhu yang tidak stabil atau berada di luar rentang yang diinginkan dapat menyebabkan kerusakan makanan, yang berpotensi mengakibatkan kerugian ekonomi dan risiko kesehatan. Oleh karena itu pengendalian suhu agar tetap stabil merupakan hal penting dalam menjaga agar kondisi makanan agar tetap fresh dan sehat. Dengan suhu yang stabil maka kualitas makanan yang kita dapat akan ideal dan layak untuk dikonsumsi.

Oleh karena itu Smart Chiller dirancang untuk mengatasi tantangan yang ada dengan mengimplementasikan sesnor dan sistem aktuator. Smart Chiller menggunakan sensor HC-SR04 untuk mendeteksi makanan yang ada didalam chiller. Jika sensor mendeteksi adanya makanan maka sensor DHT11 akan aktif untuk memonitoring suhu pada chiller dan menampilkan datanya di LCD MAX7219. 

Jika suhu terdeteksi berada di nilai yang tidak normal maka akan terdapat aktuator buzzer dan LED yang akan menyaala sebagai peringatan akan adanya masalah suhu pada chiller. Selain itu Servo akan diaktifkan untuk membantu mengembalikan suhu ke kondisi yang normal sehingga makanan yang tidak akan rusak kualitasnya.

# Hardware Implementation


### 1.  Arduino UNO 
![](https://images.tokopedia.net/img/cache/700/product-1/2015/12/22/3172078/3172078_cd1be747-4c2f-439d-b37e-cd50ef3b58ad.jpg)

### 2. Sensor HC-SR04
![](https://www.nn-digital.com/wp-content/uploads/2019/07/Sensor-HC-SR04-1.jpg)

### 3. Sensor DHT11
![](https://img.lazcdn.com/g/p/787826e16cb1522c0ca8af7d499ad81a.jpg_720x720q80.jpg)

### 4. LCD MAX7219
![](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSDqYBKkQKtxS-GQExCCylAlab6965SgDAvYRk1WbRn0A&s)

### 5. Servo SG90
![](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ65KeEWzgbZqeEMtVO-tfjVoQ_z-Fxkk3xZjwV1Apzbg&s)

### 6. Buzzer
![](https://sariteknologi.com/wp-content/uploads/2021/07/Buzzer.jpg)

### 7. LED
![](https://lh5.googleusercontent.com/proxy/CIMGbgcx4jZAO8LEgRvuukkdj6kLtAJwV1fL5zk4fLHnGrgyYBaAIi7eFubtj5jNCNNdN_GHRZx3cAQa69qXmnuiWLfAOyUAlfrcz3ogDEDAoBO-gtDTfhiPlZpnmet5)

### 8. Resistor 
![](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcT9Ur-WAN9SBZbfiOs8gsVT3SzTvUQSYw06ic-bh9iJ3Q&s)


## Testing

