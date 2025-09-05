import { Response } from 'express';
import ChatRoom from '../models/ChatRoom';
import Message from '../models/Message';
import { AuthRequest } from '../middleware/auth';

export const getChatRooms = async (req: AuthRequest, res: Response) => {
  try {
    console.log('Getting chat rooms for user:', req.user?._id);
    
    const rooms = await ChatRoom.find()
      .populate('createdBy', 'username')
      .populate('members', 'username')
      .sort({ createdAt: -1 });

    console.log(`Found ${rooms.length} rooms`);

    // Transform the response to ensure members are properly formatted
    const transformedRooms = rooms.map(room => ({
      _id: room._id,
      id: room._id,
      name: room.name,
      description: room.description,
      members: room.members.map((member: any) => member._id.toString()),
      memberDetails: room.members, // Keep full member details for future use
      createdBy: room.createdBy,
      createdAt: room.createdAt
    }));

    console.log('Transformed rooms:', transformedRooms.map(r => ({ id: r._id, name: r.name, memberCount: r.members.length })));

    res.json(transformedRooms);
  } catch (error) {
    console.error('Get chat rooms error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const createChatRoom = async (req: AuthRequest, res: Response) => {
  try {
    const { name, description } = req.body;
    const userId = req.user?._id;

    if (!userId) {
      return res.status(401).json({ message: 'User not authenticated' });
    }

    // Check if room with same name exists
    const existingRoom = await ChatRoom.findOne({ name: name.trim() });
    if (existingRoom) {
      return res.status(400).json({ message: 'Room name already exists' });
    }

    // Create new room
    const room = new ChatRoom({
      name: name.trim(),
      description: description?.trim() || '',
      members: [userId],
      createdBy: userId
    });

    await room.save();
    await room.populate([
      { path: 'createdBy', select: 'username' },
      { path: 'members', select: 'username' }
    ]);

    // Transform the response to match the format expected by frontend
    const transformedRoom = {
      _id: room._id,
      id: room._id,
      name: room.name,
      description: room.description,
      members: room.members.map((member: any) => member._id.toString()),
      memberDetails: room.members,
      createdBy: room.createdBy,
      createdAt: room.createdAt
    };

    res.status(201).json(transformedRoom);
  } catch (error: any) {
    if (error.name === 'ValidationError') {
      const messages = Object.values(error.errors).map((err: any) => err.message);
      return res.status(400).json({ message: messages[0] });
    }
    
    console.error('Create chat room error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const joinRoom = async (req: AuthRequest, res: Response) => {
  try {
    const { roomId } = req.params;
    const userId = req.user?._id;

    console.log(`Join room request - roomId: ${roomId}, userId: ${userId}`);

    if (!userId) {
      console.log('Join room failed: User not authenticated');
      return res.status(401).json({ message: 'User not authenticated' });
    }

    const room = await ChatRoom.findById(roomId);
    if (!room) {
      console.log(`Join room failed: Room not found - ${roomId}`);
      return res.status(404).json({ message: 'Chat room not found' });
    }

    console.log(`Room found: ${room.name}, current members: ${room.members.length}`);

    // Check if user is already a member
    if (room.members.includes(userId as any)) {
      console.log('User already a member - allowing access to room');
      return res.json({ message: 'Already a member of this room - access granted' });
    }

    // Add user to room
    room.members.push(userId as any);
    await room.save();

    console.log(`Successfully added user ${userId} to room ${roomId}`);
    res.json({ message: 'Successfully joined the room' });
  } catch (error) {
    console.error('Join room error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const leaveRoom = async (req: AuthRequest, res: Response) => {
  try {
    const { roomId } = req.params;
    const userId = req.user?._id;

    if (!userId) {
      return res.status(401).json({ message: 'User not authenticated' });
    }

    const room = await ChatRoom.findById(roomId);
    if (!room) {
      return res.status(404).json({ message: 'Chat room not found' });
    }

    // Remove user from room
    room.members = room.members.filter(memberId => 
      memberId.toString() !== userId.toString()
    );
    await room.save();

    res.json({ message: 'Successfully left the room' });
  } catch (error) {
    console.error('Leave room error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};

export const getRoomMessages = async (req: AuthRequest, res: Response) => {
  try {
    const { roomId } = req.params;
    const { page = 1, limit = 50 } = req.query;
    
    console.log(`Getting messages for room: ${roomId}, page: ${page}, limit: ${limit}`);
    
    const userId = req.user?._id;
    if (!userId) {
      return res.status(401).json({ message: 'User not authenticated' });
    }

    // Check if user is a member of the room
    const room = await ChatRoom.findById(roomId);
    if (!room) {
      console.log(`Room not found: ${roomId}`);
      return res.status(404).json({ message: 'Chat room not found' });
    }

    if (!room.members.includes(userId as any)) {
      console.log(`User ${userId} not a member of room ${roomId}`);
      return res.status(403).json({ message: 'Access denied - not a member of this room' });
    }

    console.log(`User ${userId} verified as member of room ${roomId}`);

    // Get messages with pagination
    const pageNum = Math.max(1, parseInt(page as string));
    const limitNum = Math.min(100, Math.max(1, parseInt(limit as string)));
    const skip = (pageNum - 1) * limitNum;

    console.log(`Querying messages with skip: ${skip}, limit: ${limitNum}`);

    const messages = await Message.find({ roomId })
      .sort({ timestamp: -1 })
      .limit(limitNum)
      .skip(skip)
      .populate('senderId', 'username');

    console.log(`Found ${messages.length} messages in database for room ${roomId}`);
    console.log(`Message details:`, messages.map(msg => ({
      id: msg._id,
      content: msg.content,
      sender: msg.senderUsername,
      timestamp: msg.timestamp
    })));

    // Reverse to get chronological order
    messages.reverse();

    res.json(messages);
  } catch (error) {
    console.error('Get room messages error:', error);
    res.status(500).json({ message: 'Internal server error' });
  }
};