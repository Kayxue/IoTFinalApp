const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8080 });

// 模擬停車場數據
let parkingData = {
  slots: Array(9).fill(false), // 9個車位，false表示空位
  totalSlots: 9,
  avaliableSlots: 9,
  gateOpen: false,
  systemReady: true
};

wss.on('connection', function connection(ws) {
  console.log('有客戶端連線了');

  // 發送初始數據
  ws.send(JSON.stringify(parkingData));

  // 模擬定期更新數據
  const interval = setInterval(() => {
    // 隨機更新一個車位狀態
    const randomIndex = Math.floor(Math.random() * parkingData.slots.length);
    parkingData.slots[randomIndex] = !parkingData.slots[randomIndex];
    
    // 更新可用車位數
    parkingData.avaliableSlots = parkingData.slots.filter(slot => !slot).length;
    
    // 發送更新後的數據
    ws.send(JSON.stringify(parkingData));
  }, 5000); // 每5秒更新一次

  ws.on('message', function incoming(message) {
    console.log('收到訊息:', message.toString());
    
    try {
      const data = JSON.parse(message);
      // 處理接收到的數據
      if (data.type === 'updateSlot') {
        const { index, occupied } = data;
        if (index >= 0 && index < parkingData.slots.length) {
          parkingData.slots[index] = occupied;
          parkingData.avaliableSlots = parkingData.slots.filter(slot => !slot).length;
          // 發送更新後的數據給所有客戶端
          wss.clients.forEach(function each(client) {
            if (client.readyState === WebSocket.OPEN) {
              client.send(JSON.stringify(parkingData));
            }
          });
        }
      }
    } catch (e) {
      console.error('處理訊息時發生錯誤:', e);
    }
  });

  ws.on('close', function close() {
    console.log('客戶端斷開連線');
    clearInterval(interval);
  });
});

console.log('WebSocket 服務器已啟動在 port 8080'); 