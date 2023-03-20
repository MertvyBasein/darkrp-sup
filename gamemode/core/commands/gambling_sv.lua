rp.cards = {
	'Туз ♥',
	'2 ♥',
	'3 ♥',
	'4 ♥',
	'5 ♥',
	'6 ♥',
	'7 ♥',
	'8 ♥',
	'9 ♥',
	'10 ♥',
	'Валет ♥',
	'Дама ♥',
	'Король ♥',
	'Туз ♦',
	'2 ♦',
	'3 ♦',
	'4 ♦',
	'5 ♦',
	'6 ♦',
	'7 ♦',
	'8 ♦',
	'9 ♦',
	'10 ♦',
	'Валет ♦',
	'Дама ♦',
	'Король ♦',
	'Туз ♣',
	'2 ♣',
	'3 ♣',
	'4 ♣',
	'5 ♣',
	'6 ♣',
	'7 ♣',
	'8 ♣',
	'9 ♣',
	'10 ♣',
	'Валет ♣',
	'Дама ♣',
	'Король ♣',
	'Туз ♠',
	'2 ♠',
	'3 ♠',
	'4 ♠',
	'5 ♠',
	'6 ♠',
	'7 ♠',
	'8 ♠',
	'9 ♠',
	'10 ♠',
	'Валет ♠',
	'Дама ♠',
	'Король ♠'
}

rp.coins = { 'Орел', 'Решка' }

rp.AddCommand('roll', function(pl, targ, message)
	chat.Send('Roll', pl, tostring(math.random(100)))
end)

rp.AddCommand('dice', function(pl, targ, message)
	chat.Send('Dice', pl, tostring(math.random(1, 6)), tostring(math.random(1, 6)))
end)

rp.AddCommand('cards', function(pl, targ, message)
	chat.Send('Cards', pl, table.Random(rp.cards))
end)

rp.AddCommand('coins', function(pl, targ, message)
	chat.Send('Coin', pl, table.Random(rp.coins))
end)
