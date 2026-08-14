const { onSchedule } = require("firebase-functions/v2/scheduler");
const admin = require("firebase-admin");
const fetch = require("node-fetch");

admin.initializeApp();

// Bounding Box para la región de Colombia y zonas limítrofes
const COLOMBIA_BOUNDS = {
  minLat: -4.2,
  maxLat: 13.5,
  minLong: -82.0,
  maxLong: -66.8,
};

// Registro en memoria de sismos notificados
const notifiedEventIds = new Set();

/**
 * Cloud Function v2 ejecutable periódicamente (Cron cada 1 minuto)
 * Consulta USGS y despacha mensajes Push FCM de Máxima Prioridad a Colombia.
 */
exports.checkColombiaEarthquakesStream = onSchedule(
  {
    schedule: "every 1 minutes",
    timeZone: "America/Bogota",
    retryCount: 1,
  },
  async (event) => {
    try {
      console.log("🔍 Monitoreando eventos sísmicos en Colombia...");

      const now = new Date();
      const fiveMinsAgo = new Date(now.getTime() - 5 * 60 * 1000);

      // Consulta a la API GeoJSON de USGS
      const url =
        `https://earthquake.usgs.gov/fdsnws/event/1/query?format=geojson` +
        `&starttime=${fiveMinsAgo.toISOString()}` +
        `&endtime=${now.toISOString()}` +
        `&minlatitude=${COLOMBIA_BOUNDS.minLat}` +
        `&maxlatitude=${COLOMBIA_BOUNDS.maxLat}` +
        `&minlongitude=${COLOMBIA_BOUNDS.minLong}` +
        `&maxlongitude=${COLOMBIA_BOUNDS.maxLong}` +
        `&minmagnitude=3.0` +
        `&orderby=time`;

      const response = await fetch(url);
      const data = await response.json();

      if (!data.features || data.features.length === 0) {
        console.log("✅ Sin eventos sísmicos relevantes en los últimos minutos.");
        return;
      }

      for (const feature of data.features) {
        const eventId = feature.id;
        const properties = feature.properties || {};
        const coordinates = feature.geometry?.coordinates || [0, 0, 0];

        const magnitude = properties.mag || 0.0;
        const place = properties.place || "Colombia";
        const longitude = coordinates[0];
        const latitude = coordinates[1];
        const depth = coordinates[2];

        // Ignorar si ya fue notificado previamente
        if (notifiedEventIds.has(eventId)) continue;

        console.log(`🚨 SISMO DETECTADO: M${magnitude} - ${place}`);

        // Payload de Notificación Push FCM de Alta Prioridad
        const payload = {
          topic: "colombia_emergency_alerts",
          notification: {
            title: `🚨 ALERTA SÍSMICA: M${magnitude.toFixed(1)}`,
            body: `Sismo registrado en ${place} (Prof: ${depth.toFixed(1)} km). ¡Mantén la calma y ubica tu zona segura!`,
          },
          data: {
            eventId: eventId,
            magnitude: magnitude.toString(),
            place: place,
            latitude: latitude.toString(),
            longitude: longitude.toString(),
            depth: depth.toString(),
            time: (properties.time || Date.now()).toString(),
          },
          android: {
            priority: "high",
            notification: {
              sound: "default",
              channelId: "sismo_emergency_alerts_v1",
              priority: "high",
              defaultVibrateTimings: true,
            },
          },
          apns: {
            payload: {
              aps: {
                sound: "default",
                badge: 1,
                "content-available": 1,
              },
            },
          },
        };

        // Despachar a todos los celulares Android / iOS suscritos
        await admin.messaging().send(payload);
        console.log(`📡 Mensaje Push FCM enviado con éxito para evento ${eventId}`);

        notifiedEventIds.add(eventId);
      }
    } catch (error) {
      console.error("❌ Error en Cloud Function:", error);
    }
  }
);
