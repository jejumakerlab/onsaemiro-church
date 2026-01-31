/**
 * Vercel Serverless Function: YouTube 최신 영상 ID 캐싱
 * - 서버에서 YouTube RSS 직접 요청 (CORS 없음)
 * - 5분 CDN 캐시로 안정적 응답
 */

const YOUTUBE_CHANNEL_ID = 'UC-EtPdnnt_Sn8uD6skXRqcA';
const RSS_URL = `https://www.youtube.com/feeds/videos.xml?channel_id=${YOUTUBE_CHANNEL_ID}`;
const CACHE_MAX_AGE = 300; // 5분 (초)

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Cache-Control', `s-maxage=${CACHE_MAX_AGE}, stale-while-revalidate=${CACHE_MAX_AGE * 2}`);

  try {
    const response = await fetch(RSS_URL, {
      headers: { 'User-Agent': 'OnsaemiroChurch/1.0' }
    });

    if (!response.ok) {
      throw new Error(`YouTube RSS failed: ${response.status}`);
    }

    const xmlText = await response.text();
    const videoId = extractVideoIdFromRss(xmlText);
    const { title, published } = extractMetadataFromRss(xmlText);

    if (!videoId) {
      return res.status(404).json({ error: 'No video found' });
    }

    return res.status(200).json({ videoId, title, published });
  } catch (error) {
    console.error('YouTube API error:', error.message);
    return res.status(500).json({ error: error.message });
  }
}

function extractVideoIdFromRss(xmlText) {
  const match = xmlText.match(/<yt:videoId>([^<]+)<\/yt:videoId>/);
  return match ? match[1] : null;
}

function extractMetadataFromRss(xmlText) {
  const titleMatch = xmlText.match(/<title>([^<]+)<\/title>/);
  const publishedMatch = xmlText.match(/<published>([^<]+)<\/published>/);
  return {
    title: titleMatch ? titleMatch[1] : '',
    published: publishedMatch ? publishedMatch[1] : ''
  };
}
