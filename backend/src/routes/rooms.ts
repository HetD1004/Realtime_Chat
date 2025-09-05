import express from 'express';
import { 
  getChatRooms, 
  createChatRoom, 
  joinRoom, 
  leaveRoom, 
  getRoomMessages,
  getRoomMessagesSince,
  sendMessageToRoom
} from '../controllers/roomController';
import { authenticateToken } from '../middleware/auth';

const router = express.Router();

// All routes are protected
router.use(authenticateToken);

router.get('/', getChatRooms);
router.post('/', createChatRoom);
router.post('/:roomId/join', joinRoom);
router.post('/:roomId/leave', leaveRoom);
router.get('/:roomId/messages', getRoomMessages);
router.get('/:roomId/messages/since', getRoomMessagesSince); // New polling endpoint
router.post('/:roomId/messages', sendMessageToRoom); // Send message endpoint

export default router;